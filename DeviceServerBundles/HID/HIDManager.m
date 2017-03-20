#import "HIDManager.h"

#define kVolumeMinimum -50.0

@implementation HIDManager

DeviceServer *ds;

- (void) awakeFromNib {
	ds = [NSApp delegate];
	//	[[NSNotificationCenter defaultCenter] postNotificationName:@"Refresh Devices" object:nil userInfo:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDevices) name:@"Refresh Devices" object:nil];
}

static void iocallback(  void *target, IOReturn result, void *refcon, void *sender, IOHIDElementCookie elementCookie) {
	// target is the device generating
	// refcon is the device
	// pRecElement theSender = sender;
	//HIDPrintElement(sender);
	IOHIDEventStruct event;
	pRecDevice dev = (pRecDevice)refcon;
	Device *device = [ds.dm deviceForUniqueID:dev->locID];
	
	pRecElement currentElement;
	while(HIDGetEvent(dev, &event)) {

		// ---- VOLUME DETECTION W/ POWERMATE
		if([device.name isEqualToString:@"Griffin PowerMate"]) {
			currentElement= HIDGetFirstDeviceElement(dev, kHIDElementTypeInput);
			while(currentElement) {
				if(event.elementCookie == currentElement->cookie) {
					float sendValue;
					if(currentElement->usage == 51) {
						sendValue = (float)event.value;
					}else if(currentElement->usage == 1) {
						sendValue = (event.value == 1) ? -1000.0 : -10000.0;
					}
					if(sendValue != -10000) 
						[me volumeChange:sendValue];
				}
				currentElement = HIDGetNextDeviceElement(currentElement, kHIDElementTypeInput);
			}
		}
		// ---- END VOLUME DETECTION
		
		currentElement = HIDGetFirstDeviceElement(dev, kHIDElementTypeInput);

		while(currentElement) {
			if(event.elementCookie == currentElement->cookie) {
				//[ds.console print:[NSString stringWithFormat:@"%d :: %d :: %f", currentElement->usagePage , currentElement->usage, (float)event.value]];

				for(NSDictionary *control in device.controls) {	
					if([[control objectForKey:@"usagePage"] intValue] == currentElement->usagePage && 
					   [[control objectForKey:@"usage"] intValue] == currentElement->usage )
					{
						[ds.am sendApplicationsValue:(float)event.value fromControlWithID:[[control objectForKey:@"id"] intValue] onDevice:device];
						if(device.polling)
							[ds.console print:[NSString stringWithFormat:@"%@ ::  %@ :: %f", device.name, [control objectForKey:@"name"], (float)event.value]];
					}
				}
				break;
			}
			currentElement = HIDGetNextDeviceElement(currentElement, kHIDElementTypeInput);
		}
	}
	
}

- (void)volumeChange:(float)changeAmount {
	OSCManager *osc = ds.osc;
	if(changeAmount == -1000) {
		mute = !mute;
		if(mute)
			[osc sendVolumeMessage:0.0f];
		else
			[osc sendVolumeMessage:[self convertDBtoLin:volumeDB]];
	}else{
		if(!mute) {
			if(changeAmount < 1){
				volumeDB = (volumeDB + (changeAmount / 2.0) > kVolumeMinimum) ? volumeDB + (changeAmount / 2.0) : kVolumeMinimum;
			}else{
				volumeDB = (volumeDB + (changeAmount / 2.0) < 0) ? volumeDB + (changeAmount / 2.0) : 0;
			}
			
			if(prevVolumeDB != volumeDB) {
				float linValue;
				linValue = [self convertDBtoLin:volumeDB];
				//NSLog(@"lin value  = %f", linValue);
				[osc sendVolumeMessage:linValue];
			}
			
			prevVolumeDB = volumeDB;
		}
	}
}

- (float)convertDBtoLin:(float)dBValue {
	float ansstart = (float)dBValue / 10.0;
	float ans = powf(10.0, ansstart);
	
	return ans;
}

- (id) init {
	if(self = [super init]) {
		[self performSelector: @selector(loadDevices)
				   withObject: nil
				   afterDelay: 0.1];
		me = self;
		mute = NO;
		volumeDB = 0;
		prevVolumeDB = 0;
		//[self loadDevices];
		ds = [NSApp delegate];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDevices) name:@"Refresh Devices" object:nil];

	}
	

	return self;
}

- (void)queueDevice:(NSString *)deviceName {
	//HIDBuildDeviceList(NULL, NULL);
	//int numDevices = HIDCountDevices();
	NSLog(@"Queue?");
	deviceCandidateHID = NULL;
	deviceCandidateHID = HIDGetFirstDevice();
	while(deviceCandidateHID) {
		if([[NSString stringWithCString:deviceCandidateHID->product] isEqualToString:deviceName]) {
			//NSLog(@"found");
			HIDQueueDevice(deviceCandidateHID);
			//printf("selected device = %s number is %d \n", deviceCandidate->product, deviceNumber);
			HIDSetQueueCallback(deviceCandidateHID, (IOHIDCallbackFunction)iocallback, nil, nil);
		}
	}
}

- (void)queueElement:(NSString *)elementName onDevice:(NSString *)deviceName usagePage:(int)usagePage usage:(int)usage {
	//HIDBuildDeviceList(NULL, NULL);
	
	deviceCandidateHID = NULL;
	if(HIDHaveDeviceList()) NSLog(@"device list present");
	deviceCandidateHID = HIDGetFirstDevice();
	BOOL elementFound = NO;
	int count = 0;
	while(deviceCandidateHID) {
		if(elementFound) break;
		NSString *deviceCheck = [NSString stringWithCString:deviceCandidateHID->product];
		if([deviceName isEqualToString:deviceCheck]) {
			pRecElement inputElement = HIDGetFirstDeviceElement(deviceCandidateHID, kHIDElementTypeInput);
			while(inputElement) {
				if(usagePage == inputElement->usagePage && usage == inputElement->usage) {
					int check = HIDSetQueueCallback(deviceCandidateHID, (IOHIDCallbackFunction)iocallback,nil, nil);
					check = HIDQueueDevice(deviceCandidateHID);
					
					NSLog(@"callback = %d", check);
					
					//elementFound = YES;
					//NSLog(@"done queueing");
					
					break;
				}
				inputElement = HIDGetNextDeviceElement(inputElement,  kHIDElementTypeInput);
			}
		}
		count++;
		deviceCandidateHID = HIDGetNextDevice( deviceCandidateHID );
	}
}

- (void)loadDevices {
	NSArray *deviceNames = ds.dm.deviceNames;
	HIDBuildDeviceList(NULL, NULL);
	//int numDevices = HIDCountDevices();
	deviceCandidateHID = NULL;
	deviceCandidateHID = HIDGetFirstDevice();
	while(deviceCandidateHID) {
		/*
		 printf("*********************************DEVICE PROFILE***************************\n");
		 printf("%s \n", deviceCandidateHID->product);
		 printf("usagePage: %i \n", deviceCandidateHID->usagePage);
		 printf("usage: %i \n", deviceCandidateHID->usage);
		 printf("locID: %i \n", deviceCandidateHID->locID);
		 printf("**************************************************************************\n\n");
		*/
		
		for(NSString * name in deviceNames) {
			NSString *deviceName = [NSString stringWithCString:deviceCandidateHID->product];
			//NSLog(@"name = %@, deviceName =%@", name, deviceName);
			if([name isEqualToString: deviceName]) {
				int check = HIDQueueDevice(deviceCandidateHID);		
				check = HIDSetQueueCallback(deviceCandidateHID, (IOHIDCallbackFunction)iocallback, nil, deviceCandidateHID);
				NSLog(@"check = %d", check);
				NSLog(@"CREATING HID DEVICE NAMED %@, unique %ld", deviceName, deviceCandidateHID->locID);
				[ds.dm createDeviceWithName:deviceName uniqueID:deviceCandidateHID->locID];
				break;
			}
		}		
		deviceCandidateHID = HIDGetNextDevice( deviceCandidateHID );
	}
}

- (void) createDeviceWithName:(NSString *)name {
	[ds.dm createDeviceWithName:name];
}

- (void) sendValue:(float)value fromControlWithID:(int)controlID {
	Device *device = [ds.dm deviceForName:@"HID"];
	
	if(device.polling)
		[ds.console print:[NSString stringWithFormat:@"%@ :: controlID %d :: value %f", device.name, controlID, value]];
	
	[ds.am sendApplicationsValue:value fromControlWithID:controlID onDevice:device];
}

- (IBAction) HIDConnect:(id)sender {
	[ds.console print:@"HID loaded"];
	[self createDeviceWithName:@"HID"];
}

- (NSString *) name { return @"HID"; }
- (BOOL) shouldDisplayInterface { return NO; }
- (NSView *) view { return view; }

@end

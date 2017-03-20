#import "MIDIManager.h"

// IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE

@implementation MIDIManager

- (BOOL) shouldDisplayInterface { return YES; }

static void notifyProc(const MIDINotification *message, void *refCon) // if MIDI setup is changed
{
	MIDIManager *midiManager = (MIDIManager *)refCon;  // create reference to midi object
	[midiManager rescanSources:midiManager];          // rescan all available midi sources
}

- (id) init {
	if(self = [super init]) {
		ds = [NSApp delegate];
		
		MIDIClientCreate(CFSTR("Device Server"), notifyProc, self, &client);
		[self rescanSources:self];
	}
	
	[self retain];
	return self;
}

static CFStringRef EndpointName(MIDIEndpointRef endpoint, bool isExternal)
{
	CFMutableStringRef result = CFStringCreateMutable(NULL, 0);
	CFStringRef str;
	
	// begin with the endpoint's name
	str = NULL;
	MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &str);
	if (str != NULL) {
		CFStringAppend(result, str);
		CFRelease(str);
	}
	
	MIDIEntityRef entity = NULL;
	MIDIEndpointGetEntity(endpoint, &entity);
	if (entity == NULL)
		// probably virtual
		return result;
	
	if (CFStringGetLength(result) == 0) {
		// endpoint name has zero length -- try the entity
		str = NULL;
		MIDIObjectGetStringProperty(entity, kMIDIPropertyName, &str);
		if (str != NULL) {
			CFStringAppend(result, str);
			CFRelease(str);
		}
	}
	// now consider the device's name
	MIDIDeviceRef device = NULL;
	MIDIEntityGetDevice(entity, &device);
	if (device == NULL)
		return result;
	
	str = NULL;
	MIDIObjectGetStringProperty(device, kMIDIPropertyName, &str);
	if (str != NULL) {
		// if an external device has only one entity, throw away
		// the endpoint name and just use the device name
		if (isExternal && MIDIDeviceGetNumberOfEntities(device) < 2) {
			CFRelease(result);
			return str;
		} else {
			// does the entity name already start with the device name?
			// (some drivers do this though they shouldn't)
			// if so, do not prepend
			if (CFStringCompareWithOptions(str /* device name */,
										   result /* endpoint name */,
										   CFRangeMake(0, CFStringGetLength(str)), 0) != kCFCompareEqualTo) {
				// prepend the device name to the entity name
				if (CFStringGetLength(result) > 0)
					CFStringInsert(result, 0, CFSTR(" "));
				CFStringInsert(result, 0, str);
			}
			CFRelease(str);
		}
	}
	return result;
}

- (IBAction) rescanSources:(id)sender {
	NSString *portName, *modelName, *uniqueName;
    int i, j;
    
	ItemCount num_sources = MIDIGetNumberOfSources();
    j = 0;
	
    for (i = 0; i < num_sources; i++) {
        MIDIEndpointRef source;
        source = MIDIGetSource(i);
		MIDIObjectGetStringProperty(source, kMIDIPropertyModel, (CFStringRef *)&modelName);
		MIDIObjectGetStringProperty(source, kMIDIPropertyName, (CFStringRef *)&portName);
		
		uniqueName = [NSString stringWithFormat:@"%@ %@", modelName, portName];
		int deviceID = [ds.dm deviceIDforName:uniqueName];
		if(deviceID != -1) {
		//NSLog(uniqueName);
			//if([portName isEqualToString:@"MIDI Port"]) {
			MIDIDevice *d = [[MIDIDevice alloc] initWithName:[NSMutableString stringWithString:uniqueName] deviceID:deviceID client:client midiSource:source];
				BOOL flag = [ds.dm addDevice:(Device *)d];
				if(flag) {
					NSLog(@"connecting");
					[d connect];
				}
				NSLog(@"%@ added", uniqueName);
		}
		//if(d != nil) NSLog(@"%@ final count %d", d.name, [d retainCount]);
		//}
    }
}



- (void) createDeviceWithName:(NSString *)name {
	[ds.dm createDeviceWithName:name];
}

- (void) sendValue:(float)value fromControlWithID:(int)controlID {
	Device *device = [ds.dm deviceForName:@"MIDI"];
	
	if(device.polling)
		[ds.console print:[NSString stringWithFormat:@"%@ :: controlID %d :: value %f", device.name, controlID, value]];
	
	[ds.am sendApplicationsValue:value fromControlWithID:controlID onDevice:device];
}

- (NSString *) name { return @"MIDI"; }
- (NSView *) view { return view; }

@end

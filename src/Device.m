//
//  Device.m
//  DeviceServer_1
//
//  Created by charlie on 10/30/08.

//

#import "Device.h"
#import "DeviceServer.h"
#import "OSCDevice.h"
#import "OSCManager.h"

@implementation Device
@synthesize name, deviceID, connectedApplications, polling, controlNames, controls, displayName, uniqueID;

- (id) initWithName:(NSMutableString *)aname deviceID:(int)aDeviceID {
	
	if (self = [super init]){
		ds = (DeviceServer *)[NSApp delegate];
		connectedApplications = [[NSMutableArray alloc] init];
		name = aname;
		[name retain];
		deviceID = aDeviceID;
		//NSLog(@"%@ :::::: %d", name, deviceID);
		@try {
			controlNames = [ds.luaManager getControlNamesForDeviceNamed:name];
		}
		@catch (id theException) {
			NSLog(@"controlname exception: %@", theException);
			return NULL;	
		}
		[controlNames retain];
		@try {
			controls = [ds.luaManager getControlDictionariesForDevice:name];
		}
		@catch (id theException) {
			NSLog(@"controls exception: %@", theException);
			return NULL;
		}
		[controls retain];
		polling = NO;

		//if([name isEqualToString:@"Wiimote"])
			//NSLog(@"device %@ description :: %@ ", name, [controlNames description]);

		

		//[self addObserver:self forKeyPath:@"polling" options:NSKeyValueObservingOptionNew context:NULL];
		
	}
	
	return self;
}

- (int) controlIDForName:(NSString *)controlName {
	for(NSDictionary *dict in controls)
		if([controlName isEqualToString:[dict objectForKey:@"name"]])
			return [[dict objectForKey:@"id"] intValue];
	
	return -1;
}

- (NSString *) controlNameForControlID:(int)controlID {
	for(NSDictionary *dict in controls) 
		if(controlID == [[dict objectForKey:@"id"] intValue]) 
			return [dict objectForKey:@"name"];
	
	return nil;
}


- (BOOL)isEqual:(id)anObject {
	BOOL result = NO;
	Device *d = (Device *)anObject;
	
	result = ([name isEqualToString:d.name] && deviceID == d.deviceID && d.uniqueID == uniqueID);
	
	return result;
}


- (NSDictionary *)controlDictForControlWithID:(int)controlID {
	for(NSDictionary *dict in controls) {
		if(controlID == [[dict objectForKey:@"id"] intValue]) {
			return dict;
		}
	}
	return nil;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"name :: %@, id :: %d, unique::%ld", name, deviceID, uniqueID];
}

- (void) outputValue:(float)value forControl:(int)controlID {
	NSDictionary *controlDict = [self controlDictForControlWithID:controlID];
	NSMutableString *controlAddress = [NSMutableString stringWithString:[controlDict objectForKey:@"name"]];
	[controlAddress replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [controlAddress length])];
	[controlAddress insertString:@"/" atIndex:0];
	
	if([self isMemberOfClass:[OSCDevice class]]) {
		OSCDevice *oscd = (OSCDevice *)self;
		NSLog(@"sending value %f to address %@ at IP %@ port %d", value, controlAddress, oscd.ipAddress, oscd.port);
		[ds.osc sendValue:value toOSCAddress:controlAddress atIP:oscd.ipAddress port:oscd.port];
	}
}

/*- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
 DeviceServer *ds = [NSApp delegate];
 if ([keyPath isEqual:@"polling"]) {
 NSLog(@"polling changed on %@", name);
 polling = [[change objectForKey:@"new"] boolValue];
 return;
 }
 
 [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
 
 }*/

- (void) dealloc {
	[controls release];
	[name release];
	[controlNames release];
	[connectedApplications release];
	[super dealloc];
}
@end

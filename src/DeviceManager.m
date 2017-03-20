//
//  DeviceManager.m
//  DeviceServer3
//
//  Created by charlie on 5/17/09.
//  Copyright 2009 One More Muse. All rights reserved.
//
#import "DeviceManager.h"
#import "OSCManager.h"
#import "DeviceServer.h"

@implementation DeviceManager
@synthesize connectedDevices, deviceNames, allDevices;

- (void) awakeFromNib {
	connectedDevices = [[NSMutableArray alloc] init];
	ds = [NSApp delegate];
}

- (void) initializeDummyDevices {
	ds = [NSApp delegate];

	allDevices = [ds.luaManager getDevices];
	[allDevices retain];
	//NSLog(@"%@", [allDevices description]);
	
	dummyDevices = [[NSMutableArray alloc] init];
	deviceNames  = [[NSMutableArray alloc] init];
	for(NSDictionary *dict in allDevices) {
		NSMutableString *name = [NSMutableString stringWithString:[dict objectForKey:@"name"]];
		int idValue = [[dict objectForKey:@"id"] intValue];
		[deviceNames addObject:name];
		Device *d = [[Device alloc] initWithName:name deviceID:idValue];
		[dummyDevices addObject:d];
		[d release];
	}
}

- (BOOL) createDeviceWithName:(NSString *)name {
	Device *d = [[Device alloc] initWithName:[NSMutableString stringWithString:name] deviceID:[self deviceIDforName:name]];
	if(d != NULL) {
		[self addDevice:d];
		//[d release];
		return YES;
	}else{
		return NO;
	}
}

- (BOOL) createDeviceWithName:(NSString *)name uniqueID:(long)uniqueID {
	Device *d = [[Device alloc] initWithName:[NSMutableString stringWithString:name] deviceID:[self deviceIDforName:name]];
	d.uniqueID = uniqueID;
	NSLog(@"unique id %ld, d.uniqueID %ld", uniqueID, d.uniqueID);
	if(d != NULL) {
		[self addDevice:d];
		//[d release];
		return YES;
	}else{
		return NO;
	}
}

- (NSDictionary *) deviceDictionaryForID:(int)deviceID { // created so id numbers can be arbitrary and not in sequence
	NSDictionary *dictToFind;
	int idNumber;
	for(NSDictionary * dict in allDevices) {
		idNumber = [[dict objectForKey:@"id"] intValue];
		if(idNumber == deviceID) {
			dictToFind = dict;
			return dictToFind;
		}
	}
	return NULL;
}

- (NSString *) deviceNameForID:(int)deviceID {
	NSDictionary *deviceDictionary = [self deviceDictionaryForID:deviceID];
	id junk = [deviceDictionary objectForKey:@"name"];
	return junk;
}

- (Device *) deviceForName:(NSString *)name uniqueID:(long)uniqueID {
	for(Device *d in connectedDevices) {
		if([d.name isEqualToString:name]) {
			if(uniqueID == d.uniqueID) { 
				return d;
			}
		}
	}
	return nil;
}

- (Device *) deviceForUniqueID:(long)uniqueID {
	//NSLog(@"id = %ld", uniqueID);
	for(Device *d in connectedDevices) {
		//NSLog(@"device check id = %ld", d.uniqueID);
		if(uniqueID == d.uniqueID) { 
			return d;
		}
	}
	return nil;
}

- (int) deviceIDforName:(NSString *)name {
	int idNumber = -1;
	NSString *deviceName;
	for(NSDictionary * dict in allDevices) {
		deviceName = [dict objectForKey:@"name"];
		if([deviceName isEqualToString:name]) {
			idNumber = [[dict objectForKey:@"id"] intValue];
			return idNumber;
		}
	}
	return idNumber;
}

- (BOOL) addDevice:(Device *)device {
	if(device == NULL) return NO;
	int count = 1;
	for(Device *d in connectedDevices) {
		if([d isEqual:device]) {
			return NO;
		}else{
			if([d.name isEqualToString:device.name] || 
			   [d.name isEqualToString:[NSString stringWithFormat:@"%@ (%d)", device.name, count, nil]]) { // sn (2), sn (3) etc.
				count++;
			}
		}
	}

	if(count != 1) {
		device.name = [NSString stringWithFormat:@"%@ (%d)", device.name, count, nil];
		device.deviceID += count - 1;
	}
	
	device.displayName = device.name;
	[ds.osc sendAllApplicationsMsg:"/deviceAdded" values:[NSArray arrayWithObject:FLOAT(device.deviceID)]];
	NSLog(@"%@", [device description]);
	[self willChangeValueForKey:@"connectedDevices"];
	[connectedDevices addObject:device];
	[self didChangeValueForKey:@"connectedDevices"];
	
	[self willChangeValueForKey:@"deviceNames"];
	[deviceNames addObject:device.name];
	[self willChangeValueForKey:@"deviceNames"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"New Device" object:device userInfo:nil];
	return YES;
}

- (Device *) deviceForName:(NSString *)name {
	for(Device *d in connectedDevices) {
		if([d.name isEqualToString:name]) return d;
	}
	return nil;
}

- (Device *) deviceForID:(int)deviceID {
	for(Device *d in connectedDevices) {
		if(d.deviceID == deviceID) return d;
	}
	return nil;
}

- (Device *) dummyDeviceForName:(NSString *)name {
	for(Device *d in dummyDevices) {
		if([d.name isEqualToString:name]) return d;
	}
	return nil;
}

- (Device *) dummyDeviceForID:(int)deviceID {
	for(Device *d in dummyDevices) {
		if(d.deviceID == deviceID) return d;
	}
	return nil;
}

- (IBAction) forceDisconnectDevice:(id)sender {
	[self willChangeValueForKey:@"connectedDevices"];
	[connectedDevices removeObjectAtIndex:[devicesTableView selectedRow]];
	[self didChangeValueForKey:@"connectedDevices"];
}

- (void) removeDevice:(NSString *)deviceName {
	// MUST MANUALLY MANAGE MEMORY..
	
	Device *d  = [self deviceForName:deviceName];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Device Removed" object:d userInfo:nil];
	NSNumber *deviceNum = [[NSNumber alloc] initWithFloat:d.deviceID];
	NSArray *oscArray = [[NSArray alloc]  initWithObjects:deviceNum, nil];
	[ds.osc sendAllApplicationsMsg:"/deviceRemoved" values:oscArray];
	[deviceNum release];
	[oscArray release];
	[self willChangeValueForKey:@"connectedDevices"];
	[connectedDevices removeObject:d];
	[self didChangeValueForKey:@"connectedDevices"];
	
	[self willChangeValueForKey:@"deviceNames"];
	[deviceNames removeObject:deviceName];
	[self willChangeValueForKey:@"deviceNames"];
}

- (IBAction) refreshList:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Refresh Devices" object:nil userInfo:nil];
	[devicesTableView setNeedsDisplay:YES];
}

- (void) test {
	[self willChangeValueForKey:@"connectedDevices"];
	[self addDevice:[[[Device alloc] initWithName:@"Joystick 1" deviceID:0] autorelease]];
	[self didChangeValueForKey:@"connectedDevices"];
	
	[self willChangeValueForKey:@"deviceNames"];	
	[deviceNames addObject:@"Joystick 1"];
	[deviceNames addObject:@"Wiimote 1"];
	[self didChangeValueForKey:@"deviceNames"];
	
	NSLog(@"END DEVICE MANAGER TEST");
}

- (void)dealloc {
	[dummyDevices release];
	[allDevices release];
	[mm release];
	[connectedDevices release];
	[deviceNames release];
	[super dealloc];
}
@end

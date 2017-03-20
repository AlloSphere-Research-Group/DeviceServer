//
//  DeviceManager.h
//  DeviceServer3
//
//  Created by charlie on 5/17/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Device.h"

@class DeviceServer;
@class MIDIManager;
@interface DeviceManager : NSObject {
	NSArray *allDevices;				    // all devices present in Master Device List
	NSMutableArray *connectedDevices;		// only devices currently connected to DS
	NSMutableArray *deviceNames;
	DeviceServer *ds;
	NSMutableArray *dummyDevices;		    // used to store device descriptions for devices that are not connected
	IBOutlet NSTableView *devicesTableView;
	MIDIManager *mm;
}

@property (retain) NSMutableArray *connectedDevices, *deviceNames;
@property (retain) NSArray *allDevices;

- (void) test;
- (NSString *)deviceNameForID:(int)deviceID;
- (int) deviceIDforName:(NSString *)name;
- (NSDictionary *) deviceDictionaryForID:(int)deviceID;
- (Device *) deviceForUniqueID:(long)uniqueID;
- (Device *) deviceForName:(NSString *)name uniqueID:(long)uniqueID;
- (Device *) dummyDeviceForName:(NSString *)name;
- (Device *) dummyDeviceForID:(int)deviceID;
- (BOOL) addDevice:(Device *)device;

- (void)     removeDevice:(NSString *)deviceName;
- (IBAction) forceDisconnectDevice:(id)sender;
- (Device *) deviceForName:(NSString *)name;

- (BOOL) createDeviceWithName:(NSString *)name;
- (BOOL) createDeviceWithName:(NSString *)name uniqueID:(long)uniqueID;

- (BOOL) addDevice:(Device *)device;
- (Device *) deviceForID:(int)deviceID;
- (IBAction) refreshList:(id)sender;

- (void) initializeDummyDevices;

@end

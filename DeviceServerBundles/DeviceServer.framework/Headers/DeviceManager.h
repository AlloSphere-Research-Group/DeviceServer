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
	NSMutableArray *devices;
	NSMutableArray *deviceNames;
	DeviceServer *ds;
	IBOutlet NSTableView *devicesTableView;
	MIDIManager *mm;
}

@property (retain) NSMutableArray *devices, *deviceNames;

- (void) test;
- (void) removeDevice:(NSString *)deviceName;
- (IBAction) forceDisconnectDevice:(id)sender;
- (Device *) deviceForName:(NSString *)name;
- (BOOL) createDeviceWithName:(NSString *)name;
- (BOOL) addDevice:(Device *)device;
- (Device *) deviceForID:(int)deviceID;
- (IBAction) refreshList:(id)sender;

@end

//
//  ApplicationManager.h
//  DeviceServer3
//
//  Created by charlie on 5/17/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Application.h"
#import "Mapping.h"
#import "Device.h"

@class DeviceServer;

@interface ApplicationManager : NSObject {
	NSMutableArray *applications;
	NSMutableArray *applicationNames;
	IBOutlet NSTableView *applicationsTableView;
	DeviceServer *ds;
}

@property (retain) NSMutableArray *applications;
@property (retain) NSMutableArray *applicationNames;

- (void) addApplicationWithName:(char *)name ipAddress:(char *)ip port:(int)port;
- (void) removeApplicationWithName:(NSString *)name;

- (Application *) applicationWithName:(NSString *)name;
- (Application *) selectedApplication;

- (IBAction) forceDisconnectApplication:(id)sender;

- (void) sendApplicationsValue:(float)value fromControlWithID:(int)controlID onDevice:(Device *)device;
- (void) sendApplicationsValues:(NSArray *)values fromControlWithID:(int)controlID onDevice:(Device *)device;

@end

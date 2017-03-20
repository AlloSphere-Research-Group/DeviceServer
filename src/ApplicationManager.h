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
	BOOL isSoloing;
	IBOutlet NSTableView	*applicationsTableView;
	IBOutlet NSWindow		*applicationCreatorWindow;
	IBOutlet NSTextField	*applicationNameField;
	IBOutlet NSTextField	*defaultImplementationField;
	IBOutlet NSWindow		*interfaceCreatorWindow;
	DeviceServer *ds;
}

@property (retain) NSMutableArray *applications;
@property (assign) BOOL isSoloing;

- (void) addApplicationWithName:(char *)name ipAddress:(char *)ip port:(int)port;
- (void) addApplicationWithName:(NSDictionary *)dict;
- (void) removeApplicationWithName:(NSString *)name;

- (IBAction) createNewApplication:(id)sender;
- (IBAction) launchNewApplicationWindow:(id)sender;
- (IBAction) newFunctionality:(id)sender;
- (IBAction) editInterface:(id)sender;
- (IBAction) saveInterface:(id)sender;

- (Application *) applicationWithName:(NSString *)name;
- (Application *) selectedApplication;
- (BOOL) applicationDirectoryDoesExist:(NSString *)appName;

- (IBAction) forceDisconnectApplication:(id)sender;
- (IBAction) refreshInterface:(id)sender;
- (IBAction) refreshImplementation:(id)sender;
- (IBAction) newMapping:(id)sender;

- (void) sendApplicationsValue:(float)value fromControlWithID:(int)controlID onDevice:(Device *)device;
- (void) sendApplicationsValue:(float)value fromControlWithID:(int)controlID onDeviceWithID:(int)deviceID;
- (void) sendApplicationsValues:(NSArray *)values fromControlWithID:(int)controlID onDevice:(Device *)device;
- (void) applicationIsSoloing:(Application *)app;
@end

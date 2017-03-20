//  Application.h
//  DeviceServer_1
//
//  Created by charlie on 11/5/08.
//  Copyright 2008 One More Muse. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Mapping.h"
#import "DeviceServer.h"

@class Device;

@interface Application : NSObject {
	NSString *name;
	NSMutableArray *scripts;
	NSMutableString *chosenScript;
	BOOL polling;
	NSMutableArray *mappings;
	NSString *ipAddress;
	int port;
	DeviceServer *ds;
}

@property (retain) NSString *name;
@property (retain) NSMutableArray *scripts;
@property (copy) NSMutableString *chosenScript;
@property (assign) BOOL polling;
@property (retain) NSMutableArray *mappings;
@property (retain) NSString *ipAddress;
@property (assign) int port;

- (id) initWithName:(char *)aName ipAddress:(char *)aIpAddress port:(int)aPort;

- (void) registerMapping:(Mapping *)mapping;
- (void) readMappings;
- (void) unregisterMapping:(Mapping *)mapping;
- (void) addScript:(NSString *)scriptName;
- (void) readScript:(NSString *)scriptName;

- (Mapping *) mappingForName:(NSString *)name;
- (void) processValue:(float)value fromControlWithID:(int)controlID onDevice:(Device *)device;
- (void) processValues:(NSArray *)values fromControlWithID:(int)controlID onDevice:(Device *)device;
- (void) addDynamicControlWithName:(NSString *)controlName
					   destination:(NSString *)destination
					  deviceNumber:(int)deviceNumber
					 controlNumber:(int)controlnumber
					   expectedMin:(float)expectedMin
					   expectedMax:(float)expectedMax
						expression:(NSString *)expression
							   cID:(int)cID;

@end

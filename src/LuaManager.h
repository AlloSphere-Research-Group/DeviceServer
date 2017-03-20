//
//  LuaManager.h
//  DeviceServer3
//
//  Created by charlie on 6/25/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <LuaCore/LuaCore.h>
#import <LuaCocoa/LuaCocoa.h>
@class Device;
@class DeviceServer;
@class Application;

@interface LuaManager : NSObject {
	DeviceServer *ds;

	NSMutableString *path;
	NSMutableString *scriptDirectory;
	NSArray *devices;

	LuaCocoa *lua;
}

@property (readonly) LuaCocoa *lua;
@property (nonatomic, assign) DeviceServer *ds;

- (void) clearStack;

- (NSArray *) getDevices;

- (NSMutableString *) saveLuaFileForApp:(Application *)app;

- (NSMutableArray *) getControlNamesForDevice:(int)deviceID;
- (NSArray *) getControlDictionariesForDevice:(NSString *)deviceName;
- (NSArray *) getMappingsForApplication:(NSString *)applicationName usingScriptNamed:(NSString *)scriptName;
- (NSArray *) scriptNamesForApplicationNamed:(NSString *)applicationName;

- (NSMutableDictionary *) controlPropertiesForControlWithID:(int)controlID onDeviceWithID:(int)deviceID;
- (NSMutableArray *) getControlNamesForDeviceNamed:(NSString *)deviceName;
- (void) pushAsLuaString:(NSString*)s withName:(NSString*)name;
- (id) objectNamed:(NSString*)name;
- (void) runBuffer:(NSString*)buf;

@end

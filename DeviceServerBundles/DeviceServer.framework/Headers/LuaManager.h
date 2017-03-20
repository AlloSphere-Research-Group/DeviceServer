//
//  LuaManager.h
//  DeviceServer3
//
//  Created by charlie on 6/25/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <LuaCore/LuaCore.h>

@class Device;
@class DeviceServer;
@class Application;

@interface LuaManager : NSObject {
	DeviceServer *ds;
	NSArray *devices;
	//IBOutlet NSTextField *pathField;
	NSMutableString *path;
	NSMutableString *scriptDirectory;	
	NSMutableArray *deviceNames;

	//IBOutlet NSWindow *preferences;
	LCLua *lua;
}

@property (readonly) LCLua *lua;
@property (readonly) NSMutableArray *deviceNames;


- (void) readSignalsForApplicationNamed:(NSString *)applicationName;
- (NSMutableString *) saveLuaFileForApp:(Application *)app;

- (int) deviceIDforName:(NSString *)name;

- (NSMutableArray *) getControlNamesForDevice:(int)deviceID;
- (NSArray *) getControlDictionariesForDevice:(NSString *)deviceName;
- (NSArray *) getMappingsForApplication:(NSString *)applicationName usingScriptNamed:(NSString *)scriptName;
- (NSArray *) scriptNamesForApplicationNamed:(NSString *)applicationName;
- (NSString *) deviceNameForID:(int)deviceID;

- (NSMutableDictionary *) controlPropertiesForControlWithID:(int)controlID onDeviceWithID:(int)deviceID;
- (NSDictionary *) deviceDictionaryForID:(int)deviceID;

/*
- (NSMutableArray *) getControlNamesForDevice:(int)deviceID;
- (NSString *) deviceNameForID:(int)deviceID;

- (NSDictionary *) controlProperties:(int)controlID withDeviceID:(int)deviceID destinationAddress:(NSString *)destinationAddress expression:(NSString *)expression;
- (NSDictionary *) getUsagePageAndUsageForControlName:(NSString *)controlName device:(Device *)device;
- (NSXMLElement *) deviceNodeForID:(int)deviceID;

- (NSArray *) deviceNames;
- (NSArray *) getControlDictionariesForDevice:(NSString *)deviceName;

- (IBAction) selectXMLPath:(id)sender;
- (IBAction) applyPreferences:(id)sender;
- (IBAction) loadScript:(id)sender;
- (IBAction) saveScriptAs:(id)sender;
- (IBAction) saveScript:(id)sender;

- (void) getFilePathWithEndSelector:(SEL)sel;
- (void) getSavePathWithEndSelector:(SEL)sel;

- (int) deviceIDforName:(NSString *)name;*/

@end

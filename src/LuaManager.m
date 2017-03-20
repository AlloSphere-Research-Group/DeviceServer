//
//  LuaManager.m
//  DeviceServer3
//
//  Created by charlie on 6/25/09.
//  Copyright 2009 One More Muse. All rights reserved.

#import "LuaManager.h"
#import "Device.h"
#import "DeviceServer.h"
#import "Application.h"
#import "ConsoleDelegate.h"
#import "ApplicationManager.h"
#import "DeviceManager.h"

@implementation LuaManager
@synthesize lua, ds;

// as taken from LuaCore
- (void) runBuffer:(NSString*)buf {
    
    // oh geeze, don't tell anyone i'm using threadDictionary!
    //[[[NSThread currentThread] threadDictionary] setObject:[NSNumber numberWithBool:YES] forKey:LCRunningInLuaKey];
    
    if (luaL_loadbuffer(lua.luaState, [buf UTF8String], [buf length], nil) || lua_pcall(lua.luaState, 0, 0, 0)) {
        //[self error:"Error: %s\n", lua_tostring(lua.luaState, -1)];
    }
    
    //[[[NSThread currentThread] threadDictionary] removeObjectForKey:LCRunningInLuaKey];
}

- (id) objectNamed:(NSString*)name {
    
    lua_getglobal(lua.luaState, [name UTF8String]);
    
	id ret = LuaCocoa_ToPropertyList(lua.luaState, -1);
    	
    if (ret == [NSNull null]) {
        return nil;
    }
    
    return ret;
}

- (void) pushAsLuaString:(NSString*)s withName:(NSString*)name {
    lua_pushstring(lua.luaState, [name UTF8String]);
    lua_pushstring(lua.luaState, [s UTF8String]);
    lua_settable(lua.luaState, LUA_GLOBALSINDEX);
}

- (id) init {
	if (self = [super init]) {
		//ds = [NSApp delegate];
		//lua = [LCLua readyLua];
		//[lua retain];
		
		lua = [[LuaCocoa alloc] init];
		//luaJIT_setmode([lua state], 0, LUAJIT_MODE_ON);
		path = [NSMutableString stringWithString:[[NSBundle mainBundle] bundlePath]];
		[path appendString:@"/Contents/Resources/deviceDescriptions/"];
		NSLog(@"path = %@", path);

		[path retain];
		
		scriptDirectory = (NSMutableString *)[[NSUserDefaults standardUserDefaults] stringForKey:@"PathToScripts"];
		
		if(scriptDirectory == nil) {
			NSMutableString *scripts = [NSMutableString stringWithString:[[NSBundle mainBundle] bundlePath]];
			[scripts appendString:@"/../../../examples/DeviceServerScripts"];
			scriptDirectory = scripts;
			[[NSUserDefaults standardUserDefaults] setObject:scriptDirectory forKey:@"PathToScripts"];
		}
		
		[scriptDirectory retain];
		//[lua pushGlobalObject:ds.console withName:@"console"];
		LuaCocoa_PushInstance(lua.luaState, ds.console);
		lua_setglobal(lua.luaState, "console");
		//[lua runBuffer:@"print(jit.version)"];
		
		//[lua runBuffer:@"DNR = DNR_NUMBER"];
		int err = 0;
		[self runBuffer:@"DNR = DNR_NUMBER"];
		[self runBuffer:@"console.print = console.print_"];		
		//err = luaL_loadBuffer(lua.luaState, "DNR = DNR_NUMBER", 16, "dnr") || lua_pcall(lua.luaState, 0,0,0);
		//err = luaL_loadBuffer(lua.luaState, "console.print = console.print_", 30, "print") || lua_pcall(lua.luaState, 0,0,0);
		//[lua runBuffer:@"console.print = console.print_"];
	}
	
	return self;
}

- (NSArray *) getDevices {
	NSString *masterDeviceListPath = [path stringByAppendingString:@"Master Device List.lua"];
	NSMutableString *cmd = [NSMutableString stringWithFormat:@"dofile(\"%@\")", masterDeviceListPath];
	[self runBuffer:cmd];
	NSArray * _devices = [NSArray arrayWithArray:[self objectNamed:@"devices"]];
	return _devices;
}

- (NSMutableString *) saveLuaFileForApp:(Application *)app {
	NSMutableString *file = (app.preMappingsImplementationCode != nil) ? [NSMutableString stringWithString:app.preMappingsImplementationCode] : [NSMutableString string];
	[file appendString:@"mappings = {"];
	
	for(Mapping *m in app.mappings) {
		if(m.isConnected) {
			[file appendString:@"\n\t{ "];
			NSString *props = [NSString stringWithFormat:@"name = \"%@\", destination = \"%@\", device = %d, control = %d, expression = \"%@\", cID = %d },",
							   m.name,
							   m.destination,
							   m.deviceID,
							   m.controlID,
							   (m.expression != nil) ? m.expression : @"",
							   m.cID ];
			[file appendString:props];
		}
	}
	[file appendString:@"\n}"];
	
	if(app.postMappingsImplementationCode != nil) 
		[file appendString:app.postMappingsImplementationCode];

	return file;
}

- (NSArray *) scriptNamesForApplicationNamed:(NSString *)applicationName {
	NSUserDefaults *std = [NSUserDefaults standardUserDefaults];
	NSMutableString *scriptPath = [NSMutableString stringWithString:[std stringForKey:@"PathToScripts"]];
	[scriptPath appendString:applicationName];
	[scriptPath appendString:@"/"];
	
	NSMutableArray *scriptNames = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] directoryContentsAtPath:scriptPath]];
	[scriptNames removeObject:@".DS_Store"];
	return scriptNames;
}

/*- (void) readSignalsForApplicationNamed:(NSString *)applicationName {
	NSUserDefaults *std = [NSUserDefaults standardUserDefaults];
	
	NSMutableString *scriptPath = [NSMutableString stringWithString:[std stringForKey:@"PathToScripts"]];
	[scriptPath appendString:[NSString stringWithFormat:@"%@/Interface.lua",applicationName,applicationName]];
	
	NSMutableString *cmd = [NSMutableString stringWithFormat:@"dofile(\"%@\")", scriptPath];
	[lua runBuffer:cmd];
	NSArray *signals = ([lua objectNamed:@"functionalities"] != nil) ? [lua objectNamed:@"functionalities"] : [lua objectNamed:@"signals"];
	
	Application *app = [ds.am applicationWithName:applicationName];
	
	for(NSDictionary * dict in signals) {
		Mapping *m = [[Mapping alloc] initWithProperties:dict];				
		[app registerMapping:m];
	}
}*/

- (NSArray *) getControlDictionariesForDevice:(NSString *)deviceName {
	NSMutableString *pathToFile = [NSMutableString stringWithString:path];
	NSArray *controls = nil;
	[pathToFile appendString:deviceName];
	[pathToFile appendString:@".lua"];
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:pathToFile];
	
	if(exists) {
		NSMutableString *cmd = [NSMutableString stringWithFormat:@"dofile(\"%@\")", pathToFile];
		
		[self runBuffer:cmd];
		
		controls = [self objectNamed:@"controls"];
	}
	
	return controls;
}

- (NSArray *) getMappingsForApplication:(NSString *)applicationName usingScriptNamed:(NSString *)scriptName {
	NSUserDefaults *std = [NSUserDefaults standardUserDefaults];
	
	NSMutableString *scriptPath = [NSMutableString stringWithString:[std stringForKey:@"PathToScripts"]];
	[scriptPath appendString:applicationName];
	[scriptPath appendString:@"/"];
	[self pushAsLuaString:scriptPath withName:@"gPwd"];
	
	[scriptPath appendString:scriptName];
	
	NSMutableString *cmd = [NSMutableString stringWithFormat:@"dofile(\"%@\")", scriptPath];
	[self runBuffer:cmd];
	
	NSArray *mappings = [self objectNamed:@"mappings"];
	
	return mappings;
}

- (NSMutableDictionary *) controlPropertiesForControlWithID:(int)controlID onDeviceWithID:(int)deviceID {
	//ds = [NSApp delegate];

	NSDictionary *deviceDict = [ds.dm deviceDictionaryForID:deviceID];
	NSString *deviceName = [deviceDict objectForKey:@"name"];
	NSMutableDictionary *controlDict = nil;
	
	NSMutableString *pathToFile = [NSMutableString stringWithString:path];
	[pathToFile appendString:deviceName];
	[pathToFile appendString:@".lua"];
	
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:pathToFile];
	
	if(exists) {
		NSMutableString *cmd = [NSMutableString stringWithFormat:@"dofile(\"%@\")", pathToFile];
		
		[self runBuffer:cmd];
		NSArray *controls = [self objectNamed:@"controls"];
		
		controlDict = [controls objectAtIndex:controlID];
	}
	
	return controlDict;
}

- (NSMutableArray *) getControlNamesForDevice:(int)deviceID {
	NSMutableArray *controlNames = [NSMutableArray array];
	NSMutableString *pathToFile = [NSMutableString stringWithString:path];
	
	NSString *deviceName = [ds.dm deviceNameForID:deviceID];
	
	[pathToFile appendString:deviceName];
	[pathToFile appendString:@".lua"];
	
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:pathToFile];
	
	if(exists) {
		NSMutableString *cmd = [NSMutableString stringWithFormat:@"dofile(\"%@\")", pathToFile];
		
		[self runBuffer:cmd];
		NSArray *controls = [self objectNamed:@"controls"];
		for(NSDictionary *dict in controls) {
			[controlNames addObject:[dict objectForKey:@"name"]];
		}
	}
	
	return controlNames;
}

- (NSMutableArray *) getControlNamesForDeviceNamed:(NSString *)deviceName {
	NSMutableArray *controlNames = [NSMutableArray array];
	NSMutableString *pathToFile = [NSMutableString stringWithString:path];
	
	[pathToFile appendString:deviceName];
	[pathToFile appendString:@".lua"];
	
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:pathToFile];
	
	if(exists) {
		NSMutableString *cmd = [NSMutableString stringWithFormat:@"dofile(\"%@\")", pathToFile];
		
		[self runBuffer:cmd];
		NSArray *controls = [self objectNamed:@"controls"];
		for(NSDictionary *dict in controls) {
			[controlNames addObject:[dict objectForKey:@"name"]];
		}
	}
	
	return controlNames;
}


- (void) clearStack {
	lua_settop(lua.luaState,0);
}

- (void) dealloc {
	[path release];
	//[lua tearDown];
	//[lua release];
	[lua release];
	[LuaCocoa collectExhaustivelyWaitUntilDone:true];

	[super dealloc];
}

@end

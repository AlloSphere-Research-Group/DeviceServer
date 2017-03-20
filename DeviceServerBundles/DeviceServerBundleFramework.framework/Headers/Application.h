//  Application.h
//  DeviceServer_1
//
//  Created by charlie on 11/5/08.

#import <Cocoa/Cocoa.h>
#import "Mapping.h"
#import "DeviceServer.h"
#import <LuaCocoa/LuaCocoa.h>
#import "lo.h"

@class Device;
@class Functionality;
@interface Application : NSObject {
	NSString *name;
	NSMutableString *defaultImplementation, *scriptDirectory;
	NSMutableArray *scripts;
	NSMutableArray *functionalities;
	NSMutableString *chosenScript;
	BOOL polling, solo, isSoloing, mute;
	NSMutableArray *mappings;
	NSString *ipAddress;
	int port;
	DeviceServer *ds;
	LuaCocoa *lua;
	
	lo_address address;
	
	NSString *preMappingsImplementationCode;
	NSString *postMappingsImplementationCode;
	NSString *preFunctionalitiesInterfaceCode;
	NSString *postFunctionalitiesInterfaceCode;	
}

@property (readonly) lo_address address;
@property (retain) NSString *name, *postFunctionalitiesInterfaceCode, *preFunctionalitiesInterfaceCode, *postMappingsImplementationCode, *preMappingsImplementationCode;
@property (retain) NSMutableArray *scripts;
@property (retain) NSMutableArray *functionalities;
@property (copy) NSMutableString *chosenScript;
@property (retain) NSMutableString *defaultImplementation;
@property (assign) BOOL polling, mute, solo, isSoloing;
@property (retain) NSMutableArray *mappings;
@property (retain) NSString *ipAddress;
@property (assign) int port;
@property (readonly) LuaCocoa *lua;

- (Mapping *) mappingWithProperties:(NSDictionary *)dict;

- (id) initWithName:(char *)aName ipAddress:(char *)aIpAddress port:(int)aPort;
- (Functionality *) functionalityWithName:(NSString *)functionalityName;

- (void) addFunctionality;
- (void) registerMapping:(Mapping *)mapping;
- (void) readMappings;
- (void) unregisterMapping:(Mapping *)mapping;
- (void) addScript:(NSString *)scriptName;
- (void) readScript:(NSString *)scriptName;
- (void) sendValue:(float)value forMapping:(Mapping *)mapping;
- (void) outputMessageWithAddress:(NSString *)oscAddress value:(float)value;

- (void) initializeLua;
- (void) clearLuaStack;

- (void) mappingIsSoloing:(Mapping *)mapping;
- (Mapping *) mappingForName:(NSString *)name;

- (void) refreshInterface;
- (void) refreshImplementation;
- (void) addNewMapping;

- (void) processValue:(float)value fromControlWithID:(int)controlID onDevice:(Device *)device;
- (void) processValue:(float)value fromControlWithID:(int)controlID onDeviceWithID:(int)deviceID;
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

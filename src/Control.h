//
//  Control.h
//  DeviceServer_1
//
//  Created by charlie on 11/6/08.
//  Copyright 2008 One More Muse. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ExpressionParser.h"
@class Device;
@class Application;
@interface Control : NSObject {
	int usage;
	int usagePage;
	int deviceID;
	int controlID;
	int cID;
	
	float min;
	float max;
	float expectedMin;
	float expectedMax;
	float scalar;
	float offset;
	
	float value;

	NSString *name;
	NSString *deviceName;
	Device *device;

	NSString *destination;
	NSString *expression;
	NSString *luaExpression;
	
	BOOL polling;
	BOOL isConnected;
	
	NSMutableDictionary *dictionary;
	NSMutableArray *output;
}

@property (copy) NSString *name, *deviceName, *expression;
@property (retain) Device *device;
@property (copy) NSString *destination, *luaExpression;
@property (nonatomic, assign) int usagePage, usage, deviceID, controlID, cID;
@property (nonatomic, assign) float min, max, expectedMin, expectedMax, scalar, value;
@property (nonatomic, assign) BOOL polling, isConnected;
@property (nonatomic, retain) NSMutableDictionary *dictionary;
@property (nonatomic, readonly) NSMutableArray *output;

- (id) initWithProperties:(NSDictionary *)props;
//- (id) initWithProps:(NSDictionary *)props device:(Device *)adevice cID:(int)acID;
- (void) sendValue:(float)value toApp:(Application *)app;
- (void) sendValues:(NSArray *)values toApp:(Application *)app;
- (void) setDevice:(int)newDeviceID control:(int)newControlID expression:(NSMutableString *)newExpression cID:(int)newcID;
- (void) checkConnectionForNewDevice:(id)notification;

@end
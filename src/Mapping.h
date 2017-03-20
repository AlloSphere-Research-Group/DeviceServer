//
//  Control.h
//  DeviceServer_1
//
//  Created by charlie on 11/6/08.

//

#import <Cocoa/Cocoa.h>
#import "ExpressionParser.h"

@class Device;
@class Application;
@class Functionality;

@interface Mapping : NSObject {
	int usage;
	int usagePage;
	int deviceID;
	int controlID;
	int cID;
	int expressionID;
	
	float rawX;
	float min;
	float max;
	float expectedMin;
	float expectedMax;
	float deviceRange;
	float expectedRange;
	float scalar;
	float offset;
	
	float value;
	float preExpressionValue;

	Application *application;
	NSString *name;
	NSString *controlName;
	NSString *deviceName;
	Device *device;
	
	DeviceServer *ds;

	NSString *destination;
	NSString *expression;
	NSString *luaExpression;
	
	BOOL polling, solo, isConnected, isDeviceConnected, isDynamic;
	
	NSMutableDictionary *dictionary;
	NSMutableArray *output;
}

@property (retain) NSString *name, *deviceName, *expression, *controlName;
@property (nonatomic, assign) DeviceServer *ds;
@property (retain) Device *device;
@property (retain) NSString *destination, *luaExpression;
@property (nonatomic, assign) int usagePage, usage, deviceID, controlID, cID, expressionID;
@property (nonatomic, assign) float min, max, expectedMin, expectedMax, scalar, value, rawX, offset, preExpressionValue, deviceRange, expectedRange;
@property (nonatomic, assign) BOOL polling, isDeviceConnected, isConnected, isDynamic, solo;
@property (nonatomic, retain) NSMutableDictionary *dictionary;
@property (nonatomic, retain) NSMutableArray *output;
@property (nonatomic, retain) Application *application;

- (id) initWithFunctionality:(Functionality *)f;
- (id) initWithProperties:(NSDictionary *)props;
//- (id) initWithProps:(NSDictionary *)props device:(Device *)adevice cID:(int)acID;
- (void) sendValue:(float)value toApp:(Application *)app;
- (void) sendValues:(NSArray *)values toApp:(Application *)app;
- (void) setDevice:(int)newDeviceID control:(int)newControlID expression:(NSMutableString *)newExpression cID:(int)newcID;
- (void) checkConnectionForNewDevice:(id)notification;
- (void) checkExistingConnectionsForDeviceRemoval:(id)notification;
- (void) storeOutput:(NSNumber *)value;
- (Mapping *) copy;

@end
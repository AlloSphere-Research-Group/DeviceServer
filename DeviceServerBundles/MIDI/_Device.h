#import <Cocoa/Cocoa.h>

@class Application;
@class DeviceServer;

@interface _Device : NSObject {	
	NSMutableString *name;
	NSMutableString *displayName;
	int deviceID;
	long uniqueID;
	int idSuffix;
	BOOL polling;
	BOOL isConnected;
	NSMutableArray *connectedApplications;
	NSMutableArray *controlNames;
	NSArray *controls; // holds dictionaries describing controls NOT CONTROL OBJECTS
	DeviceServer *ds;
}

@property (retain) NSMutableArray *controlNames, *connectedApplications;
@property (retain) NSArray *controls;
@property (retain) NSMutableString *name, *displayName;
@property (nonatomic) int deviceID, idSuffix;
@property (nonatomic) long uniqueID;
@property (nonatomic) BOOL polling;

- (id) initWithName:(NSMutableString *)aname deviceID:(int)aDeviceID;
- (int) controlIDForName:(NSString *)controlName;
- (NSDictionary *) controlDictForControlWithID:(int)controlID;
- (NSString *) controlNameForControlID:(int)controlID;
- (BOOL) isEqual:(id)anObject;
- (void) outputValue:(float)value forControl:(int)controlID;

@end 

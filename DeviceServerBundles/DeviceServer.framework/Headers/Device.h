#import <Cocoa/Cocoa.h>

@class Application;
@class DeviceServer;

@interface Device : NSObject {	
	NSMutableString *name;
	int deviceID;
	BOOL polling;
	NSMutableArray *connectedApplications;
	NSMutableArray *controlNames;
	NSArray *controls; // holds dictionaries describing controls NOT CONTROL OBJECTS
	DeviceServer *ds;
}

@property (retain) NSMutableArray *controlNames, *connectedApplications;
@property (retain) NSArray *controls;
@property (copy) NSMutableString *name;
@property (assign) int deviceID;
@property (assign) BOOL polling;

- (id) initWithName:(NSMutableString *)aname deviceID:(int)aDeviceID;
- (int) controlIDForName:(NSString *)controlName;
- (NSString *) controlNameForControlID:(int)controlID;
- (BOOL) isEqual:(id)anObject;

@end 

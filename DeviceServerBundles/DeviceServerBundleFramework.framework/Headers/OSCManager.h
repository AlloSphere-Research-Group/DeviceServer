//
//  OSCManager.h
//  Server
//
//  Created by charlie on 5/27/08.

#import <Cocoa/Cocoa.h>
#import "lo.h"
#import "DeviceServer.h"
#import "Mapping.h"
#import "Application.h"
#import "ApplicationManager.h"
#import "DeviceManager.h"
#import "OSCDevice.h"

DeviceServer *ds;

int count;

@interface OSCManager : NSObject {
	lo_server_thread st;
	IBOutlet id address;
	IBOutlet id applicationAddress;
	IBOutlet id pptPortField;
	IBOutlet id pptAddressField;
	NSMutableDictionary *applications;
	char * oscReceivePort;
	//lo_address destAddress;
}

@property (readonly) char * oscReceivePort;

int registerScripts_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int generic_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int iphone_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int registerOSCDevice_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int removeOSCDevice_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int handshake_handler(const char *path, const char *types, lo_arg **argv, int argc, lo_message msg, void *user_data);
int connectMapping_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int disconnectDevice_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int disconnectMapping_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int disconnectApplication_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int changeMappingWithDestination_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int oscDeviceMessage_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int connectDynamicControl_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int output_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data);
int handshake_handlerWithIP(const char *path, const char *types, lo_arg **argv, int argc, lo_message msg, void *user_data);
//void error(int num, const char *msg, const char *path);

- (lo_server_thread)getServerThread;
- (void)sendValue:(float)value toDestination:(NSString *)dest atIPAddress:(NSString *)ip port:(int)port cID:(int)cID;
- (void)sendValue:(float)value forMapping:(Mapping *)mapping toApp:(Application *)app;
- (void)sendValues:(NSArray *)values forMapping:(Mapping *)mapping toApp:(Application *)app;
- (void)sendVolumeMessage:(float)volume;
- (void)sendAllApplicationsMsg:(char *)msgPath values:(NSArray *)values;
- (void)sendAllApplicationsMsg:(char *)msgPath values:(NSArray *)values typeTags:(char *)types;
- (void)callConfigurationScript:(NSString *)scriptName withApp:(Application *)app;
- (void)sendValue:(float)value toOSCAddress:(NSString *)address atIP:(NSString *)ip port:(int)port;
- (void)sendValues:(NSArray *)values toOSCAddress:(NSString *)address atIP:(NSString *)ip port:(int)port;


@end

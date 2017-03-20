#import "OSCManager.h"

@implementation OSCManager
@synthesize oscReceivePort;

-(void)awakeFromNib {
	ds = (DeviceServer *)[NSApp delegate];
	oscReceivePort = OSC_RECEIVE_PORT;
	
	st = lo_server_thread_new(OSC_RECEIVE_PORT, nil);
	
	lo_server_thread_add_method(st, "/registerDevice", "ssi", registerOSCDevice_handler, NULL);				 // name, ip address, port
	lo_server_thread_add_method(st, "/unregisterDevice", "s", removeOSCDevice_handler, NULL);	
	lo_server_thread_add_method(st, "/handshake", "si", handshake_handler, NULL);							 // app name, ip address, port to send notifcations to
	lo_server_thread_add_method(st, "/handshake", "ssi", handshake_handlerWithIP, NULL);					 // app name, ip address, port to send notifcations to
	
	lo_server_thread_add_method(st, "/disconnectApplication", "s", disconnectApplication_handler, NULL);	 // app name
	lo_server_thread_add_method(st, "/iphone", NULL, iphone_handler, NULL);
	lo_server_thread_add_method(st, "/OSCDeviceMsg", NULL, oscDeviceMessage_handler, NULL);					 // device name, control name, values...
	lo_server_thread_add_method(st, "/connectControl", "sssiiffsi", connectDynamicControl_handler, NULL);	 // application, name, destination, device, control, expectedMin, expectedMax, expression, cID 
	lo_server_thread_add_method(st, "/output", "ssf", output_handler, NULL);	 // application, oscaddress, value

	lo_server_thread_start(st);
	[self retain];
	count = 0;
}
	
- (lo_server_thread) getServerThread { 
	return st; 
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	lo_server_thread_free(st);
}

- (void)callConfigurationScript:(NSString *)scriptName withApp:(Application *)app {
	//lo_address destAddress  = lo_address_new([app.ipAddress UTF8String], [[INT(app.port) stringValue] UTF8String]);
	lo_send(app.address, "/runConfigurationScript", "s", [scriptName UTF8String]);
	[ds.console print:[NSString stringWithFormat:@"%@ configuration script sent to app %@", scriptName, app.name]];
}

// below should be abstracted to an array of arguments instead of one value and a cID

- (void)sendValue:(float)value toDestination:(NSString *)dest atIPAddress:(NSString *)ip port:(int)port cID:(int)cID{
	int err;
	//char portString[6];
	//snprintf(portString, sizeof(portString), "%i\0", port);
	lo_address destAddress  = lo_address_new([ip UTF8String], [[NSString stringWithFormat:@"%d", port] UTF8String]);
	
	if(cID != NO_CONTROL_ID) {
		err = lo_send(destAddress, [dest UTF8String], "fi", value, cID);
	}else{
		err = lo_send(destAddress, [dest UTF8String], "f", value);
	}
	
	lo_address_free(destAddress);
	if(err == -1) NSLog(@"error");
}

- (void)sendValue:(float)value forMapping:(Mapping *)mapping toApp:(Application *)app {
	int err;

	NSString *dest = mapping.destination;
	//NSLog(@"sending osc to ip %@ and port %d :: value %f", app.ipAddress, app.port, value);

	//lo_address destAddress  = lo_address_new([app.ipAddress UTF8String], [[INT(app.port) stringValue] UTF8String]);
	if(mapping.cID != NO_CONTROL_ID) {
		err = lo_send(app.address, [dest UTF8String], "fi", value, mapping.cID);
	}else{
		err = lo_send(app.address, [dest UTF8String], "f", value);
	}
	
	if(err == -1) NSLog(@"error");
}

- (void)sendValues:(NSArray *)values forMapping:(Mapping *)mapping toApp:(Application *)app {
	int i;
	lo_message msg = lo_message_new();
	for(i = 0; i < [values count]; i++) {
		lo_message_add_float(msg, [[values objectAtIndex:i] floatValue]);
	}
	
	if(mapping.cID != NO_CONTROL_ID) {
		lo_message_add_int32(msg, mapping.cID);
	}
	
	NSString *destPath = mapping.destination;
	//lo_address destAddress  = lo_address_new([app.ipAddress UTF8String], [[INT(app.port) stringValue] UTF8String]);
	
	lo_send_message (app.address, [destPath UTF8String], msg);
	
}

- (void)sendAllApplicationsMsg:(char *)msgPath values:(NSArray *)values {
	lo_message msg = lo_message_new();
	
	for(int i = 0; i < [values count]; i++) {
		lo_message_add_float(msg, [[values objectAtIndex:i] floatValue]);
	}
		
	for(Application *app in ds.am.applications) {
		//lo_address destAddress  = lo_address_new([app.ipAddress UTF8String], [[INT(app.port) stringValue] UTF8String]);
		lo_send_message (app.address, msgPath, msg);
	}
}

- (void)sendAllApplicationsMsg:(char *)msgPath values:(NSArray *)values typeTags:(char *)types {
	lo_message msg = lo_message_new();
	
	for(int i = 0; i < [values count]; i++) {
		switch(types[i]) {
			case 'f':
				lo_message_add_float(msg, [[values objectAtIndex:i] floatValue]);
				break;
			case 's':
				lo_message_add_string(msg, [[values objectAtIndex:i] UTF8String]);
				break;
		}
	}
	
	for(Application *app in ds.am.applications) {	
		//lo_address destAddress  = lo_address_new([app.ipAddress UTF8String], [[INT(app.port) stringValue] UTF8String]);
		lo_send_message (app.address, msgPath, msg);
	}
}

- (void)sendVolumeMessage:(float)volume {
	for(Application *app in ds.am.applications) {
		//lo_address destAddress  = lo_address_new([app.ipAddress UTF8String], [[INT(app.port) stringValue] UTF8String]);
		lo_send(app.address, "/volume", "f", volume);
	}
	// brutal hack to work around mchb setup
	lo_address destAddress  = lo_address_new("127.0.0.1", "50001");
	lo_send(destAddress, "/volume", "f", volume);
	lo_address_free(destAddress);
}

- (void)sendValue:(float)value toOSCAddress:(NSString *)address atIP:(NSString *)ip port:(int)port {
	lo_address destAddress  = lo_address_new([ip UTF8String], [[NSString stringWithFormat:@"%d", port] UTF8String]);
	lo_send(destAddress, [address UTF8String], "f", value);
	lo_address_free(destAddress);
	
}

- (void)sendValues:(NSArray *)values toOSCAddress:(NSString *)address atIP:(NSString *)ip port:(int)port {
	lo_address destAddress  = lo_address_new([ip UTF8String], [[NSString stringWithFormat:@"%d", port] UTF8String]);
	
	int i;
	lo_message msg = lo_message_new();
	for(i = 0; i < [values count]; i++) {
		lo_message_add_float(msg, [[values objectAtIndex:i] floatValue]);
	}
	
	lo_send_message (destAddress, [address UTF8String], msg);
	lo_address_free(destAddress);	
}

int handshake_handler(const char *path, const char *types, lo_arg **argv, int argc, lo_message msg, void *user_data) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int err;
	
	

	NSString *nameValue = [NSString stringWithCString:(char *)argv[0] encoding:1];	
	NSString *ipValue, *portValue;
	
	if(argc == 2) {	// no ip address provided
		lo_address a = lo_message_get_source(msg);
		ipValue = [NSString stringWithCString:lo_address_get_hostname(a) encoding:1];
		portValue = [NSString stringWithFormat:@"%d", argv[1]->i]; // must be called first... get_source screws up the message somehow		
	}else{
		ipValue =   [NSString stringWithCString:(char *)argv[1] encoding:1];
		portValue = [NSString stringWithFormat:@"%d", argv[2]->i]; //[NSNumber numberWithInt:argv[2]->i];
	}	
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:nameValue,	@"name",
																	ipValue,	@"ip",
																	portValue,	@"port", nil];
	
	NSString *_msg = [[NSString alloc] initWithFormat:@"Handshake received from %@ at IP %@ and Port %@\n", nameValue, ipValue, portValue];
	[ds.console print:_msg];
	[_msg release];
	[ds.am performSelectorOnMainThread:@selector(addApplicationWithName:) withObject:dict waitUntilDone:YES];
	
	BOOL handshakeSuccess = NO;
	for(Application *app in ds.am.applications) {
		if([app.name isEqualToString:nameValue]) {
			handshakeSuccess = YES;
			break;
		}
	}
	if(handshakeSuccess == NO) 
		[ds.console print:[NSString stringWithFormat:@"Handshake Error: Directory for application %@ not found", nameValue]];
		
	lo_address appAddress = lo_address_new([ipValue UTF8String], [portValue UTF8String]);//[[[NSNumber numberWithInt:argv[2]->i] stringValue] UTF8String]); 
	err = lo_send(appAddress, "/handshake", "i", handshakeSuccess);
	
	if(err == -1) 
		[ds.console print:@"Handhsake Error: OSC communication with application failed"];

	lo_address_free(appAddress);
	
	[pool release];
	return 0;
}

int handshake_handlerWithIP(const char *path, const char *types, lo_arg **argv, int argc, lo_message msg, void *user_data) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int err;
	
	//NSString *msg = [[NSString alloc] initWithFormat:@"Handshake received from %s at IP %s and Port %d\n", (char *)argv[0], (char *)argv[1], argv[2]->i];
	//[ds.console print:msg];
	//[msg release];
	
	NSString *name = [[NSString alloc] initWithCString:"name"];
	NSString *nameValue = [[NSString alloc] initWithCString:(char *)argv[0]];
	
	NSString *ip = [[NSString alloc] initWithCString:"ip"];
	NSString *port = [[NSString alloc] initWithCString:"port"];
	
	NSString *ipValue, *portValue;
	
	if(argc == 2) {	// no ip address provided
		portValue = [[NSNumber alloc] initWithInt:(int)argv[1]->i]; // must be called first... get_source screws up the message somehow
		
		lo_address a = lo_message_get_source(msg);
		ipValue = [[NSString alloc] initWithCString:lo_address_get_hostname(a)];
	}else{
		ipValue = [[NSString alloc] initWithCString:(char *)argv[1]];
		portValue = [[NSNumber alloc] initWithInt:argv[2]->i];
	}	
	
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:nameValue, name,
						  ipValue, ip,
						  portValue, port, nil];
	
	[ds.am performSelectorOnMainThread:@selector(addApplicationWithName:) withObject:dict waitUntilDone:YES];
	
	[name release]; [ip release]; [port release]; [nameValue release]; [portValue release]; [ipValue release]; [dict release];
	
	lo_address appAddress = lo_address_new((char *)argv[1], "9999");//[[[NSNumber numberWithInt:argv[2]->i] stringValue] UTF8String]); 
	err = lo_send(appAddress, "/handshake", "");
	if(err == -1) [ds.console print:@"Error handshaking with application"];
	
	[pool release];
	return 0;
}

int disconnectApplication_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *applicationName = [NSString stringWithCString:(char *)argv[0] encoding:1];
	[ds.am removeApplicationWithName:applicationName];
	[pool drain];
	return 0;
}

int generic_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data) {
	//NSString *applicationName = [NSString stringWithCString:(char *)argv[0] encoding:1];
	printf("path is :: %s, types are %s \n", path, types);
	return 1;
}

int iphone_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data) {
	//[oscDeviceManager processMessageWithTypes:types arguments:argv numberOfArgs:argc];
	return 0;
}

int registerOSCDevice_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//NSLog(@"device handshake");
	NSMutableString *deviceName = [NSMutableString stringWithCString:(char *)argv[0] encoding:1];
	//NSLog(@"%@", deviceName);
	//NSLog(@"ip = %s", (char *)argv[1]);
	OSCDevice *d = [[OSCDevice alloc] initWithName:deviceName deviceID:[ds.dm deviceIDforName:deviceName]];
	//NSLog([d description]);
	d.ipAddress = [[NSString alloc] initWithCString:(char *)argv[1] encoding:1];
	d.port = argv[2]->i;
	//NSLog(@"registering %@", d.ipAddress);
	[ds.dm addDevice:d];
	
	[pool release];

	return 0;
}

int oscDeviceMessage_handler(const char *path, const char *types, lo_arg **argv, int argc, lo_message msg, void *user_data) { 
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	/*lo_address l = lo_message_get_source(msg);
	NSLog(@"host address is %s", lo_address_get_hostname(l));
	char * hostName = (char *)lo_address_get_hostname(l);
	char * port = (char *)lo_address_get_port(l);
	NSLog(@"port = %s", port);*/
	
	//OSCDevice *device;
	OSCDevice *device= (OSCDevice *)[ds.dm deviceForName:[NSString stringWithCString:(char *)argv[0] encoding:1]];
	
	/*for(Device *d in ds.dm.devices) {
		if([d class] == [OSCDevice class]) {
			OSCDevice *dev = (OSCDevice *)d;
			NSLog([dev description]);
			NSLog(@"hostname = %s, dev.ipAddress = %@, port = %d", hostName, dev.ipAddress, port);
			if([dev.ipAddress isEqualToString:[NSString stringWithCString:hostName encoding:1]] && dev.port == port)
				NSLog(@"DEVICE FOUND");
		}
	}*/
		
	[device processMessageWithValues:argv count:argc types:types];

	[pool release];
	return 0; 
}

int removeOSCDevice_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[ds.dm removeDevice:[NSString stringWithCString:(char *)argv[0] encoding:1]];
	
	[pool drain];
	
	return 0;
}

int connectDynamicControl_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *applicationName = [NSString stringWithCString:(char *)argv[0] encoding:1];
	Application *app = [ds.am applicationWithName:applicationName];
	[app addDynamicControlWithName: [NSString stringWithCString:(char *)argv[1] encoding:1]
					   destination: [NSString stringWithCString:(char *)argv[2] encoding:1]
					  deviceNumber: argv[3]->i
					 controlNumber: argv[4]->i
					   expectedMin: argv[5]->f
					   expectedMax: argv[6]->f
						expression: [NSString stringWithCString:(char *)argv[7] encoding:1]
							   cID: argv[8]->i];
		
	[pool drain];
	
	return 0;
}

int output_handler(const char *path, const char *types, lo_arg **argv, int argc, void *data, void *user_data) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *applicationName = [NSString stringWithCString:(char *)argv[0] encoding:1];
	Application *app = [ds.am applicationWithName:applicationName];
	
	NSString *oscAddress = [NSString stringWithCString:(char *)argv[1] encoding:1];
	float value = argv[2]->f;
	//NSLog(@"appName = %@, oscAddress = %@, value = %f", applicationName, oscAddress, value);
	
	[app outputMessageWithAddress:oscAddress value:value];
	[pool drain];
	
	return 0;
}

// application, name, device, control, expression, cID 
	

- (void) dealloc {	
    [super dealloc];
}
@end

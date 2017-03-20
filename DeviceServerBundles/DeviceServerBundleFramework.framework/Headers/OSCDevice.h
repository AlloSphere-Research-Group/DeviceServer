//
//  OSCDevice.h
//  DeviceServer3
//
//  Created by charlie on 5/26/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Device.h"
#import "lo.h"

@interface OSCDevice : Device {
	NSString *ipAddress;
	int port;
}

- (void) processMessageWithValues:(lo_arg **)argv count:(int)count types:(const char *)types;

@property (assign) NSString *ipAddress;
@property (assign) int port;

@end

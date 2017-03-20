//
//  MIDIDevice.h
//  DeviceServer3
//
//  Created by charlie on 9/29/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreMIDI/CoreMIDI.h>

#import "_Device.h"

@interface MIDIDevice : _Device {
	MIDIClientRef client;
	MIDIPortRef inPort;
	MIDIEndpointRef mSource;
}

- (void) midiProcess:(MIDIPacketList *)pktlist endpoint:(MIDIPortRef *)connRefCon;
- (id) initWithName:(NSMutableString *)aname deviceID:(int)aDeviceID client:(MIDIClientRef)clientRef midiSource:(MIDIEndpointRef)source;
- (void) connect;

@end

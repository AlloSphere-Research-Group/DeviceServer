//
//  MIDIDevice.m
//  DeviceServer3
//
//  Created by charlie on 9/29/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import "MIDIDevice.h"
//#import <DeviceServer/DeviceManager.h>
#import <DeviceServer/DeviceServer.h>
//#import <DeviceServer/ApplicationManager.h>

@implementation MIDIDevice
static void readProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon) {
	MIDIDevice *midiDevice = (MIDIDevice *)refCon;	// creates reference for midiMe object from refCon created with Input Port creation method
	[midiDevice midiProcess:(MIDIPacketList *)pktlist endpoint:(MIDIPortRef *)connRefCon];
}


- (void) midiProcess:(MIDIPacketList *)pktlist endpoint:(MIDIPortRef *)connRefCon {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int channel;
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet;  // remove const (!)
	NSString *type, *controlName;
	int packetStart = packet->data[0]; // remembers original type and channel of message before altering
	
	if ((packetStart>>4) == 0x09) { type = @"noteon"; }	// noteOn
	if ((packetStart>>4) == 0x08) { type = @"noteoff"; }	// noteOff
	if ((packetStart>>4) == 0x0b) { type = @"cc"; }		// cc
	if ((packetStart>>4) == 0x0e) { type = @"pitchbend"; }		// pitchbend
	if ((packetStart) == 0xfe)    { type = @"as"; }		// activeSensing
	if ((packetStart) == 0xf8)	  { type = @"clock"; } // clock
	if ((packetStart>>4) == 0x0c) { type = @"programchange"; }
	if ((packetStart) == 0xf0) { type = @"sysex"; }
	
	if([type isEqualToString: @"as"] || [type isEqualToString:@"sysex"]) 
		return;
	else
		channel = ((packetStart &= 15) + 1);
	
	if([type isEqualToString:@"noteon"] || [type isEqualToString:@"noteoff"] || [type isEqualToString:@"cc"])
		controlName = [NSString stringWithFormat:@"%@ %d", type, packet->data[1]];
	else
		controlName = type;
	
	int controlID = [self controlIDForName:controlName];
	
	if(self.polling)
		[ds.console print:[NSString stringWithFormat:@"%@ :: control id %d :: device id %d :: value %f", controlName, controlID, deviceID, (float)(packet->data[2]) ]];
	
	[ds.am sendApplicationsValue:(float)(packet->data[2]) fromControlWithID:controlID onDevice:(Device *)self];
	
	[pool release];
}

- (void) connect {
	MIDIInputPortCreate(client, (CFStringRef)name, readProc, self, &inPort);
	MIDIPortConnectSource(inPort, mSource, mSource);
}

- (id) initWithName:(NSMutableString *)aname deviceID:(int)aDeviceID client:(MIDIClientRef)clientRef midiSource:(MIDIEndpointRef)source {
	//SInt32 dn;

	if(self = [super initWithName:aname deviceID:aDeviceID]) {
		client = clientRef;
		mSource = source;
		//MIDIObjectGetIntegerProperty(mSource, kMIDIPropertyConnectionUniqueID, &dn);
		//[name appendString:[NSString stringWithFormat:@" %d", dn]];
	}else{
		return NULL;
	}
	return self;
}

@end

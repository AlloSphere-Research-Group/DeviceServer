//
//  PhaseSpaceManager.h
//  PhaseSpace
//
//  IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE
 
#import <Cocoa/Cocoa.h>
#import <DeviceServer/DeviceServer.h>
#import <DeviceServer/Device.h>
#import <DeviceServer/DeviceManager.h>
#import <DeviceServer/ApplicationManager.h>
#import <DeviceServer/OSCManager.h>

#include <iostream>
#include <algorithm>
#include <vector>
#include <string>

#include "net_utils.h"
#include "owl_scan.h"
#include "owl_utils.h"
#include "owl.h"
#include "owl_math.h"
#include "timer.h"

#define MARKER_COUNT 3


@interface PhaseSpaceManager : NSObject {
	IBOutlet NSTextField *PhaseSpaceField1;
	IBOutlet NSTextField *PhaseSpaceField2;
	IBOutlet NSView *view;
	DeviceServer *ds;
	
	OWLRigid rigid;
	OWLMarker markers[MARKER_COUNT];

	OWLConnection cons;
	
	int _pollCount;
	int pollCount;
}

- (NSString *) name;
- (NSView *) view;
- (BOOL) shouldDisplayInterface;
- (IBAction) PhaseSpaceConnect:(id)sender;
- (IBAction) PhaseSpaceDisconnect:(id)sender;
- (void) receiveThread;
- (void) sendValue:(float)value fromControlWithID:(int)controlID;

@end

//
//  QuintilianManager.h
//  Quintilian
//
//  IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE
 
/* MUST BE INCLUDED IN ALL TEMPLATES */
#import <Cocoa/Cocoa.h>
#import <DeviceServer/DeviceServer.h>
#import <DeviceServer/Device.h>
#import <DeviceServer/DeviceManager.h>
#import <DeviceServer/ApplicationManager.h>
#import <DeviceServer/OSCManager.h>
/* END MUST INCLUDES */

#include <iostream>
#include "hand.h"
#include "sVector3D.h"
/* OWL Server Includes and definitions */
#include "owl.h"
#define MARKER_COUNT 180
#define SERVER_NAME "192.168.0.127"
#define INIT_FLAGS 0
#define SET_OWL_FREQUENCY 10.0f

@interface QuintilianManager : NSObject {
	IBOutlet NSTextField *QuintilianField1;
	IBOutlet NSTextField *QuintilianField2;
	IBOutlet NSView *view;
	DeviceServer *ds;
}

- (NSString *) name;
- (NSView *) view;
- (BOOL) shouldDisplayInterface;
- (IBAction) QuintilianConnect:(id)sender;

/* Below method should be removed or modified */
- (void) receivePSDataThread;
- (void) sendValue:(float)value fromControlWithID:(int)controlID;

@end

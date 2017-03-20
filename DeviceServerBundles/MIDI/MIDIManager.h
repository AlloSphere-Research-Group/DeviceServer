//
//  MIDIManager.h
//  MIDI
//
//  IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE
 
/* MUST BE INCLUDED IN ALL TEMPLATES */
#import <Cocoa/Cocoa.h>
#import <DeviceServer/DeviceServer.h>
#import <DeviceServer/Device.h>
#import <DeviceServer/DeviceManager.h>
//#import <DeviceServer/ApplicationManager.h>
/* END MUST INCLUDES */

#import <CoreMIDI/CoreMIDI.h>
#import "MIDIDevice.h"

@interface MIDIManager : NSObject {
	MIDIClientRef client;
    MIDIPortRef inPort;
	MIDIEndpointRef chosenInput1;
	NSMutableArray *availableInputs;
	
	DeviceServer *ds;
	IBOutlet NSView *view;
}

- (NSString *) name;
- (BOOL) shouldDisplayInterface;
- (IBAction) rescanSources:(id)sender;
- (NSView *) view;

/* Below method should be removed or modified */
- (void) sendValue:(float)value fromControlWithID:(int)controlID;

@end

//
//  RecordManager.h
//  Record
//
//  IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE
 
/* MUST BE INCLUDED IN ALL TEMPLATES */
#import <Cocoa/Cocoa.h>
#import <DeviceServer/DeviceServer.h>
#import <DeviceServer/Device.h>
#import <DeviceServer/DeviceManager.h>
#import <DeviceServer/ApplicationManager.h>
#import "Recording.h"
#import <LuaCocoa/LuaCocoa.h>

/* END MUST INCLUDES */

@interface RecordManager : NSArrayController {
	IBOutlet NSTableView *recordingsTableView;
	IBOutlet NSView *view;
	DeviceServer *ds;
	Recording *currentRecording;
	BOOL isRecording;
	NSDate *recordStartTime;
	LuaCocoa *lua;
}

- (NSString *) name;
- (NSView *) view;
- (BOOL) shouldDisplayInterface;

- (IBAction) record:(id)sender;
- (IBAction) stop:(id)sender;
- (IBAction) save:(id)sender;
- (IBAction) load:(id)sender;
- (IBAction) play:(id)sender;

- (NSMutableString *) saveLuaFileForRecording:(Recording *)recording;
- (void) getOpenPathWithEndSelector:(SEL)sel;


/* Below method should be removed or modified */
- (void) sendValue:(float)value fromControlWithID:(int)controlID;

@end

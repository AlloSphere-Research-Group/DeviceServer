//
//  AudioManager.h
//  Audio
//
//  IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE
 
/* MUST BE INCLUDED IN ALL TEMPLATES */
#import <Cocoa/Cocoa.h>
#import <DeviceServer/DeviceServer.h>
#import <DeviceServer/Device.h>
#import <DeviceServer/DeviceManager.h>
#import <DeviceServer/ApplicationManager.h>
#import <Quartz/Quartz.h>
/* END MUST INCLUDES */

@interface AudioManager : NSObject {
	IBOutlet QCView *qcView;
	IBOutlet id qcpc;
	IBOutlet NSView *view;
	int spectrumCount;
	int volumeCount;
	DeviceServer *ds;
}

- (NSString *) name;
- (NSView *) view;
- (BOOL) shouldDisplayInterface;
- (IBAction) AudioConnect:(id)sender;

/* Below method should be removed or modified */
- (void) exampleCallback:(NSTimer *)timer;
- (void) sendValue:(float)value fromControlWithID:(int)controlID;

@end

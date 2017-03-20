//
//  HIDManager.h
//  HID
//
//  IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE
 
/* MUST BE INCLUDED IN ALL TEMPLATES */
#import <Cocoa/Cocoa.h>
#import <DeviceServer/DeviceServer.h>
#import <DeviceServer/Device.h>
#import <DeviceServer/DeviceManager.h>
#import <DeviceServer/ApplicationManager.h>
/* END MUST INCLUDES */

#import <ApplicationServices/ApplicationServices.h>
#import "HID_Utilities_External.h"
#import <Kernel/IOKit/hidsystem/IOHIDUsageTables.h>
#import <DeviceServer/OSCManager.h>
@class HIDManager;
HIDManager *me;

@interface HIDManager : NSObject {
	IBOutlet NSView *view;
	
	pRecDevice deviceCandidateHID;
	BOOL mute;
	float volumeDB;
	float prevVolumeDB;
}

- (NSString *) name;
- (NSView *) view;
- (BOOL) shouldDisplayInterface;
- (IBAction) HIDConnect:(id)sender;

- (void)volumeChange:(float)changeAmount;
- (void)loadDevices;
- (void)queueDevice:(NSString *)deviceName;
- (void)queueElement:(NSString *)elementName onDevice:(NSString *)deviceName usagePage:(int)usagePage usage:(int)usage;
- (float)convertDBtoLin:(float)dBValue;

/* Below method should be removed or modified */
- (void) sendValue:(float)value fromControlWithID:(int)controlID;

@end
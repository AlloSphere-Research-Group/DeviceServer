//
//  ÇPROJECTNAMEÈManager.h
//  ÇPROJECTNAMEÈ
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

@interface ÇPROJECTNAMEÈManager : NSObject {
	IBOutlet NSTextField *ÇPROJECTNAMEÈField1;
	IBOutlet NSTextField *ÇPROJECTNAMEÈField2;
	IBOutlet NSView *view;
	DeviceServer *ds;
}

- (NSString *) name;
- (NSView *) view;
- (BOOL) shouldDisplayInterface;
- (IBAction) ÇPROJECTNAMEÈConnect:(id)sender;

/* Below method should be removed or modified */
- (void) exampleCallback:(NSTimer *)timer;
- (void) sendValue:(float)value fromControlWithID:(int)controlID;

@end

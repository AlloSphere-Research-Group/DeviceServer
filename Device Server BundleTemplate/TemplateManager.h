//
//  �PROJECTNAME�Manager.h
//  �PROJECTNAME�
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

@interface �PROJECTNAME�Manager : NSObject {
	IBOutlet NSTextField *�PROJECTNAME�Field1;
	IBOutlet NSTextField *�PROJECTNAME�Field2;
	IBOutlet NSView *view;
	DeviceServer *ds;
}

- (NSString *) name;
- (NSView *) view;
- (BOOL) shouldDisplayInterface;
- (IBAction) �PROJECTNAME�Connect:(id)sender;

/* Below method should be removed or modified */
- (void) exampleCallback:(NSTimer *)timer;
- (void) sendValue:(float)value fromControlWithID:(int)controlID;

@end

//
//  KeyboardManager.h
//  Keyboard
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

@interface KeyboardManager : NSObject {
	IBOutlet NSTextField *KeyboardField1;
	IBOutlet NSTextField *KeyboardField2;
	IBOutlet NSView *view;
	DeviceServer *ds;
	
	CFMachPortRef eventTap;
	CFRunLoopSourceRef runLoopSource;
}

- (NSString *) name;
- (NSView *) view;
- (BOOL) shouldDisplayInterface;
- (IBAction) KeyboardConnect:(id)sender;

/* Below method should be removed or modified */
- (void) exampleCallback:(NSTimer *)timer;
- (void) sendValue:(float)value fromControlWithID:(int)controlID;

@end

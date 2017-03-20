#import "KeyboardManager.h"

// IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE

@implementation KeyboardManager

int isEnabled;
int isShiftDown;
int isOptionDown;
int isControlDown;
int isCommandDown;

CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef theEvent, void *refcon) {
	UniCharCount l;
	UniChar unicodeString[1];
	CGEventKeyboardGetUnicodeString (theEvent, 1, &l, unicodeString);
	int keyCode = CGEventGetIntegerValueField(theEvent,  kCGKeyboardEventKeycode);
	//int isShiftDown = CGEventGetFlags(theEvent) & kCGEventFlagMaskShift;
	
	//printf("char count is %d :: string is %s :: keyCode is %d\n", l, unicodeString, keyCode);
	
	KeyboardManager *me = (KeyboardManager *)refcon;
	int isKeyDownEvent;
	
	//if(type != kCGEventFlagsChanged) {
		if(keyCode == 55) {
			isCommandDown = !isCommandDown;
			isKeyDownEvent = isCommandDown;
		}else if (keyCode == 56) {
			isShiftDown = !isShiftDown;
			isKeyDownEvent = isShiftDown;
		}else if (keyCode == 58) {
			isOptionDown = !isOptionDown;
			isKeyDownEvent = isOptionDown;
		}else if (keyCode == 59) {
			isControlDown = !isControlDown;
			isKeyDownEvent = isControlDown;
		}else{
			isKeyDownEvent = CGEventGetType(theEvent) == kCGEventKeyDown;
		}
		
		[me sendValue:isKeyDownEvent fromControlWithID:keyCode];
	/*}else{
		if(CGEventGetFlags(theEvent) & kCGEventFlagMaskShift != isShiftDown) {
			NSLog(@"SHIFT");
			isShiftDown = CGEventGetFlags(theEvent) & kCGEventFlagMaskShift;
			[me sendValue:isShiftDown fromControlWithID:56];
		}else if(CGEventGetFlags(theEvent) & kCGEventFlagMaskAlternate != isOptionDown) {
			isOptionDown = CGEventGetFlags(theEvent) & kCGEventFlagMaskAlternate;
			[me sendValue:isOptionDown fromControlWithID:58];
		}else if(CGEventGetFlags(theEvent) & kCGEventFlagMaskCommand != isCommandDown) {
			isCommandDown = CGEventGetFlags(theEvent) & kCGEventFlagMaskCommand;
			[me sendValue:isCommandDown fromControlWithID:55];		
		}else if(CGEventGetFlags(theEvent) & kCGEventFlagMaskControl != isControlDown) {
			isControlDown = CGEventGetFlags(theEvent) & kCGEventFlagMaskControl;
			[me sendValue:isControlDown fromControlWithID:59];			
		}else{
			NSLog(@"no flag found");
		}
	}
	*/
    return theEvent;
}

- (void) awakeFromNib {
	isShiftDown = 0; isOptionDown = 0; isCommandDown = 0; isControlDown = 0;
	
	[KeyboardField1 setStringValue:@"Test String 1"];
	[KeyboardField2 setStringValue:@"Keyboard"];
	ds = [NSApp delegate];
	[ds.dm createDeviceWithName:@"Keyboard"];

	
	// example message triggering... for example purposes only. Triggers a message to be sent every second
	//[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(exampleCallback:) userInfo:nil repeats:YES];
	
	eventTap = CGEventTapCreate(kCGHIDEventTap,
					kCGHeadInsertEventTap, 
					kCGEventTapOptionListenOnly, 
					CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp) | CGEventMaskBit(kCGEventFlagsChanged),
					myCGEventCallback,
					self);

	runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);

	CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
	CGEventTapEnable(eventTap, true);
	
	isEnabled = YES;
	//[enableButton setTitle:@"Disable SpaceBlocker"];
}

- (void) exampleCallback:(NSTimer *)timer {
	[self sendValue:9999.0f fromControlWithID:0];
}

- (void) createDeviceWithName:(NSString *)name {
	[ds.dm createDeviceWithName:name];
}

- (void) sendValue:(float)value fromControlWithID:(int)controlID {
	Device *device = [ds.dm deviceForName:@"Keyboard"];
	
	if(device.polling)
		[ds.console print:[NSString stringWithFormat:@"%@ :: controlID %d :: name %@ :: value %f", device.name, controlID, [device controlNameForControlID:controlID], value]];
	
	[ds.am sendApplicationsValue:value fromControlWithID:controlID onDevice:device];
}

- (IBAction) KeyboardConnect:(id)sender {
	[ds.console print:@"Keyboard loaded"];
	[self createDeviceWithName:@"Keyboard"];
}

- (NSString *) name { return @"Keyboard"; }
- (BOOL) shouldDisplayInterface { return NO; }
- (NSView *) view { return view; }

- (void) dealloc {
	if(CFMachPortIsValid(eventTap)) {
		CFMachPortInvalidate(eventTap);
		CFRunLoopSourceInvalidate(runLoopSource);
		CFRelease(eventTap);
		CFRelease(runLoopSource);
	}
	[super dealloc];
}

@end

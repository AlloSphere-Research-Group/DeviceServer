#import "�PROJECTNAME�Manager.h"

// IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE

@implementation �PROJECTNAME�Manager

- (id) init {
	if(self = [super init]) {}
	return self;
}

- (void) awakeFromNib {
	[�PROJECTNAME�Field1 setStringValue:@"Test String 1"];
	[�PROJECTNAME�Field2 setStringValue:@"�PROJECTNAME�"];
	ds = [NSApp delegate];
	
	// example message triggering... for example purposes only. Triggers a message to be sent every second
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(exampleCallback:) userInfo:nil repeats:YES];
}

- (void) exampleCallback:(NSTimer *)timer {
	[self sendValue:9999.0f fromControlWithID:0];
}

- (void) createDeviceWithName:(NSString *)name {
	[ds.dm createDeviceWithName:name];
}

- (void) sendValue:(float)value fromControlWithID:(int)controlID {
	Device *device = [ds.dm deviceForName:@"�PROJECTNAME�"];
	
	if(device.polling)
		[ds.console print:[NSString stringWithFormat:@"%@ :: controlID %d :: value %f", device.name, controlID, value]];
	
	[ds.am sendApplicationsValue:value fromControlWithID:controlID onDevice:device];
}

- (IBAction) �PROJECTNAME�Connect:(id)sender {
	[ds.console print:@"�PROJECTNAME� loaded"];
	[self createDeviceWithName:@"�PROJECTNAME�"];
}

- (NSString *) name { return @"�PROJECTNAME�"; }
- (BOOL) shouldDisplayInterface { return YES; }
- (NSView *) view { return view; }

@end

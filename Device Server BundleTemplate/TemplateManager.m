#import "ÇPROJECTNAMEÈManager.h"

// IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE

@implementation ÇPROJECTNAMEÈManager

- (id) init {
	if(self = [super init]) {}
	return self;
}

- (void) awakeFromNib {
	[ÇPROJECTNAMEÈField1 setStringValue:@"Test String 1"];
	[ÇPROJECTNAMEÈField2 setStringValue:@"ÇPROJECTNAMEÈ"];
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
	Device *device = [ds.dm deviceForName:@"ÇPROJECTNAMEÈ"];
	
	if(device.polling)
		[ds.console print:[NSString stringWithFormat:@"%@ :: controlID %d :: value %f", device.name, controlID, value]];
	
	[ds.am sendApplicationsValue:value fromControlWithID:controlID onDevice:device];
}

- (IBAction) ÇPROJECTNAMEÈConnect:(id)sender {
	[ds.console print:@"ÇPROJECTNAMEÈ loaded"];
	[self createDeviceWithName:@"ÇPROJECTNAMEÈ"];
}

- (NSString *) name { return @"ÇPROJECTNAMEÈ"; }
- (BOOL) shouldDisplayInterface { return YES; }
- (NSView *) view { return view; }

@end

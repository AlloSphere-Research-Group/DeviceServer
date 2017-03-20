#import "AudioManager.h"
#define BAND_COUNT 12
// IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE

@implementation AudioManager

- (id) init {
	if(self = [super init]) {}
	return self;
}

- (void) awakeFromNib {
	ds = [NSApp delegate];
	[qcpc addObserver:self forKeyPath:@"patch.Spectrum.value" options:0 context:NULL];
	[qcpc addObserver:self forKeyPath:@"patch.Volume_Peak.value" options:0 context:NULL];
	spectrumCount = 0;
	volumeCount = 0;
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
						 change:(NSDictionary*)change context:(void*)context {
	
	id qcStruct;
	if([keyPath isEqualToString:@"patch.Spectrum.value"]) {
		qcStruct = [[[qcpc patch] valueForKey:@"Spectrum"] valueForKey:@"object"];
		
		for(int i = 0; i < BAND_COUNT; i++)
			[self sendValue:[[qcStruct memberAtIndex:i] floatValue] fromControlWithID:i];
	}else{
		NSNumber *n = [[[qcpc patch] valueForKey:@"Volume_Peak"] value];
		[self sendValue:[n floatValue] fromControlWithID:BAND_COUNT];
	}

}

- (void) exampleCallback:(NSTimer *)timer {
	[self sendValue:9999.0f fromControlWithID:0];
}

- (void) createDeviceWithName:(NSString *)name {
	[ds.dm createDeviceWithName:name];
}

- (void) sendValue:(float)value fromControlWithID:(int)controlID {
	Device *device = [ds.dm deviceForName:@"Audio"];
	
	if(device.polling && spectrumCount++ % 51 == 0 )
		[ds.console print:[NSString stringWithFormat:@"%@ :: deviceID %d :: control %@ :: value %f", device.name, device.deviceID, [device controlNameForControlID:controlID], value]];

	if(device.polling && controlID == BAND_COUNT && volumeCount++ % 25 == 0 )
		[ds.console print:[NSString stringWithFormat:@"%@ :: deviceID %d :: control %@ :: value %f", device.name, device.deviceID, [device controlNameForControlID:controlID], value]];
	
	[ds.am sendApplicationsValue:value fromControlWithID:controlID onDevice:device];
}

- (IBAction) AudioConnect:(id)sender {
	[ds.console print:@"Audio loaded"];
	[self createDeviceWithName:@"Audio"];
}

- (NSString *) name { return @"Audio"; }
- (BOOL) shouldDisplayInterface { return YES; }
- (NSView *) view { return view; }

@end

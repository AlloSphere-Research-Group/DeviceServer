#import "RecordManager.h"
#import "lo.h"

@implementation RecordManager

- (id) init {
	if(self = [super init]) {
		NSString *frameworkPath=[[[NSBundle bundleForClass:[self class]] bundlePath]
								 stringByAppendingPathComponent:@"Contents/Frameworks/LuaCocoa.framework"];
        
		NSBundle *framework=[NSBundle bundleWithPath:frameworkPath];
		
		if([framework load]) {
			//NSLog(@"Framework loaded");
		}else{
			NSLog(@"Error, framework failed to load\nAborting.");
			exit(1);
		}
		
	}
	return self;
}

- (void) awakeFromNib {
	ds = [NSApp delegate];
	lua = [[LuaCocoa alloc] init];

	isRecording = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordData:) name:@"control message" object:nil];
}

- (IBAction) play:(id)sender {
	//[NSThread detachNewThreadSelector:@selector(play:) toTarget:[[self selectedObjects] objectAtIndex:0] withObject:nil];
	[[[self selectedObjects] objectAtIndex:0] play:nil];
}

- (IBAction) record:(id)sender {
	if([self selectionIndex] != NSNotFound) {
		isRecording = YES;
		if(recordStartTime != nil) [recordStartTime release];
		recordStartTime = [[NSDate alloc] init];
		currentRecording = [[self selectedObjects] objectAtIndex:0];
	}
}

- (IBAction) stop:(id)sender {
	isRecording = NO;
}

- (void) recordData:(NSNotification *)notification {
	if(isRecording) {
		NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
		double offsetTime = [[NSDate date] timeIntervalSinceDate:recordStartTime];
		[event setObject:[NSNumber numberWithDouble:offsetTime] forKey:@"offset"];
		[currentRecording addEvent:event];
	}
}

- (void) getSavePathWithEndSelector:(SEL)sel {
	NSSavePanel *oPanel = [NSSavePanel savePanel];
	NSMutableString *startingDir = [NSMutableString stringWithString:NSHomeDirectory()];
	Recording *R = (Recording *)([[self selectedObjects] objectAtIndex:0]);
	[startingDir appendString:R.name];

	[oPanel beginSheetForDirectory:startingDir
							  file:nil
					modalForWindow:[NSApp keyWindow]
					 modalDelegate:self
					didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
					   contextInfo:nil];  	
}

- (IBAction) save:(id)sender {
	//[self saveLuaFileForRecording:currentRecording];
	[self getSavePathWithEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)];
}

- (IBAction) load:(id)sender {
	[self getOpenPathWithEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)];
}
- (void) sendValue:(float)value fromControlWithID:(int)controlID {
	Device *device = [ds.dm deviceForName:@"Record"];
	
	if(device.polling)
		[ds.console print:[NSString stringWithFormat:@"%@ :: controlID %d :: value %f", device.name, controlID, value]];
	
	[ds.am sendApplicationsValue:value fromControlWithID:controlID onDevice:device];
}

- (void) savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	NSMutableString *pathToFile;
    if (returnCode == NSOKButton) 
		pathToFile = [NSMutableString stringWithString:[sheet filename]];
	else
		return;
	
	NSMutableString *script = [self saveLuaFileForRecording:currentRecording];
	
	[script writeToFile:pathToFile atomically:YES encoding:1 error:NULL];
}

- (NSMutableString *) saveLuaFileForRecording:(Recording *)recording {
	NSMutableString *file = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"name = \"%@\"\nevents = {", recording.name]];
	for(NSMutableDictionary *e in recording.events) {
		[file appendString:@"\n\t{ "];
		NSString *props = [NSString stringWithFormat:@"offset = \"%lf\", value = %f, deviceID = %d, controlID = %d },",
			[[e objectForKey:@"offset"] doubleValue],
			[[e objectForKey:@"value"] floatValue],
			[[e objectForKey:@"deviceID"] intValue],
			[[e objectForKey:@"controlID"] intValue]
		];
		[file appendString:props];
	}
	[file appendString:@"\n}"];
	return file;
}

- (void) getOpenPathWithEndSelector:(SEL)sel {
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    NSString *startingDir = [[NSUserDefaults standardUserDefaults] objectForKey:@"StartingDirectory"];
    if (!startingDir)
        startingDir = NSHomeDirectory();
    [oPanel setAllowsMultipleSelection:NO];
	[oPanel setCanChooseDirectories:YES];
    [oPanel beginSheetForDirectory:startingDir 
							  file:nil 
							 types:nil
					modalForWindow:[NSApp keyWindow] modalDelegate:self
					didEndSelector:sel
					   contextInfo:nil];
}

- (void) openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    NSMutableString *pathToFile;
    if (returnCode == NSOKButton) {
		pathToFile = [NSMutableString stringWithString:[[sheet filenames] objectAtIndex:0]];
	}else{
		return;
	}
	
	NSMutableString *cmd = [NSMutableString stringWithFormat:@"dofile(\"%@\")", pathToFile];
	luaL_loadbuffer(lua.luaState, [cmd UTF8String], [cmd length], nil) || lua_pcall(lua.luaState, 0, 0, 0);
	//[lua runBuffer:cmd];
	NSArray *events = [lua objectNamed:@"events"];
	Recording *r = [[Recording alloc] initWithName:[lua stringNamed:@"name"]];
	for(NSDictionary *d in events) {
		[r addEvent:[NSMutableDictionary dictionaryWithDictionary:d]];
	}
	[self addObject:r];
	//NSLog([r.events description]);
	
}


- (NSString *) name { return @"Record"; }
- (BOOL) shouldDisplayInterface { return YES; }
- (NSView *) view { return view; }

- (void) dealloc {
	[lua release];
	[super dealloc];
}
@end

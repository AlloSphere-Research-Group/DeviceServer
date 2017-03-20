//
//  DeviceServer.m
//  DeviceServer3
//
//  Created by charlie on 5/18/09.
//  Copyright 2009 One More Muse. All rights reserved.
// ApplicationController

#import "DeviceServer.h"
#import "ApplicationManager.h"
#import "DeviceManager.h"
#import "BonjourManager.h"

@implementation DeviceServer
@synthesize am, osc, dm, ep, logField, console, controlsTable, luaManager;

- (id)init {
	if(self = [super init]) {
		luaManager = [[LuaManager alloc] init];

		//if(luaManager != nil) NSLog(@"LUA LUA LUA");
	}
	
	return self;
}
- (void)awakeFromNib {
	luaManager.ds = self;
	[dm initializeDummyDevices];

	ep = [[ExpressionParser alloc] init];

	bonjourManager = [[BonjourManager alloc] init];
	[bonjourManager startService];
}

- (IBAction) openPreferences:(id)sender {
	[preferences makeKeyAndOrderFront:self];
	pathField.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"PathToScripts"];
}

- (void) getFilePathWithEndSelector:(SEL)sel {
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

- (IBAction) applyPreferences:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[pathField stringValue]  forKey:@"PathToScripts"];
	/*NSString *msgText = @"Please restart the Device Server";
	NSString *info = @"The Device Server must be restarted to reflect the changes made to the Scripts location";
	[[NSAlert alertWithMessageText:msgText defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:info] runModal];*/
	[preferences close];
}

- (IBAction) selectPathToScripts:(id)sender {
	SEL sel = @selector(openPanelDidEnd:returnCode:contextInfo:);
	[self getFilePathWithEndSelector:sel];
}

- (IBAction) saveScriptAs:(id)sender {
	SEL sel = @selector(saveScriptPathSelected:returnCode:contextInfo:);
	[self getSavePathWithEndSelector:sel];
}

- (IBAction) saveScript:(id)sender {
	NSMutableString *pathToFile = [NSMutableString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"PathToScripts"]];
	Application *app = [am selectedApplication];
	[pathToFile appendString:app.name];
	[pathToFile appendString:@"/"];
	[pathToFile appendString:app.chosenScript];
	NSMutableString *script = [luaManager saveLuaFileForApp:app];
	[script writeToFile:pathToFile atomically:YES encoding:1 error:NULL];
}

- (void) openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    NSMutableString *pathToFile;
    if (returnCode == NSOKButton) pathToFile = [NSMutableString stringWithString:[[sheet filenames] objectAtIndex:0]];
    if (pathToFile) {
		[pathToFile appendString:@"/"];
		[pathField setStringValue:pathToFile];
	}
}

- (void) getSavePathWithEndSelector:(SEL)sel {
	NSSavePanel *oPanel = [NSSavePanel savePanel];
    NSMutableString *startingDir = [NSMutableString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"PathToScripts"]];
	if (!startingDir) {
		startingDir = [NSMutableString stringWithString:NSHomeDirectory()];
	}else{
		Application *app = [am selectedApplication];
		[startingDir appendString:app.name];
	}
	
	[oPanel beginSheetForDirectory:startingDir
							  file:nil
					modalForWindow:[NSApp keyWindow]
					 modalDelegate:self
					didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
					   contextInfo:nil];  	
}

- (void) savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	NSMutableString *pathToFile;
    if (returnCode == NSOKButton) 
		pathToFile = [NSMutableString stringWithString:[sheet filename]];
	else
		return;
	
	Application *app = [am selectedApplication];
	NSMutableString *script = [luaManager saveLuaFileForApp:app];
	
	[script writeToFile:pathToFile atomically:YES encoding:1 error:NULL];
	
	[app addScript:[pathToFile lastPathComponent]];
	app.chosenScript = [NSMutableString stringWithString:[pathToFile lastPathComponent]];
}

- (void)dealloc {
	[bonjourManager release];
	[luaManager release];
	[ep release];
	[super dealloc];
}

@end

//
//  DeviceServer.h
//  DeviceServer3
//
//  Created by charlie on 5/18/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "HIDManager.h"
#import "ExpressionParser.h"
#import <LuaCore/LuaCore.h>
#import "LuaManager.h"

@class ApplicationManager;
@class XMLManager;
@class DeviceManager;
@class OSCManager;
@class ConsoleDelegate;
@class MIDIManager;

@interface DeviceServer : NSObject {
	IBOutlet ApplicationManager *am;
	IBOutlet XMLManager *xml;
	IBOutlet DeviceManager *dm;
	IBOutlet OSCManager *osc;
	IBOutlet NSTextView *logField;
	IBOutlet ConsoleDelegate *console;
	IBOutlet NSTableView *controlsTable;
	
	IBOutlet NSTextField *pathField;
	IBOutlet NSPanel *preferences;
	LuaManager *luaManager;
	//HIDManager *hm;
	//MIDIManager *mm;
	ExpressionParser *ep;
	lua_State* interpreter;
}

- (IBAction) openPreferences:(id)sender;
- (IBAction) selectPathToScripts:(id)sender;
- (IBAction) applyPreferences:(id)sender;
- (IBAction) saveScriptAs:(id)sender;
- (IBAction) saveScript:(id)sender;

- (void) getFilePathWithEndSelector:(SEL)sel;
- (void) getSavePathWithEndSelector:(SEL)sel;


@property (nonatomic, retain) IBOutlet ApplicationManager *am;
//@property (nonatomic, retain) IBOutlet MIDIManager *mm;
@property (nonatomic, retain) IBOutlet XMLManager *xml;
@property (nonatomic, retain) IBOutlet DeviceManager *dm;
@property (nonatomic, retain) IBOutlet OSCManager *osc;
@property (nonatomic, retain) IBOutlet NSTextView *logField;
@property (nonatomic, retain) IBOutlet ExpressionParser *ep;
@property (nonatomic, retain) IBOutlet ConsoleDelegate *console;
@property (nonatomic, retain) IBOutlet NSTableView *controlsTable;
@property (nonatomic, retain) LuaManager *luaManager;

@end
 
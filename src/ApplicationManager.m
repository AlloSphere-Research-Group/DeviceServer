//
//  ApplicationManager.m
//  DeviceServer3
//
//  Created by charlie on 5/17/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import "ApplicationManager.h"
#import "DeviceServer.h"
#import "Functionality.h"

@implementation ApplicationManager
@synthesize applications, isSoloing;

- (void)awakeFromNib {
	applications = [[NSMutableArray array] retain];
	ds = [NSApp delegate];
	self.isSoloing = NO;
}

- (void)addApplicationWithName:(NSDictionary *)dict {
	BOOL shouldAdd = YES;
	Application *a = [[Application alloc] initWithName:(char *)[[dict objectForKey:@"name"] UTF8String]
											 ipAddress:(char *)[[dict objectForKey:@"ip"] UTF8String]
												  port:[[dict objectForKey:@"port"] intValue]];
	
	for(Application *_a in applications) {
		if([a isEqual:_a]) shouldAdd = NO;
	}
	
	if(![self applicationDirectoryDoesExist:a.name]) shouldAdd = NO;
	
	if(shouldAdd) {
		[self willChangeValueForKey:@"applications"];
		[applications addObject:a];
		[self didChangeValueForKey:@"applications"];
		
		[a readMappings];
		a.chosenScript = (a.defaultImplementation != nil) ? a.defaultImplementation : @"Default.lua";
	}
}

- (BOOL)applicationDirectoryDoesExist:(NSString *)appName {
	NSUserDefaults *std = [NSUserDefaults standardUserDefaults];
	
	NSMutableString *appDirectoryPath = [NSMutableString stringWithString:[std stringForKey:@"PathToScripts"]];
	[appDirectoryPath appendString:appName];
	[appDirectoryPath appendString:@"/"];
	
	NSLog(appDirectoryPath);
	NSFileManager *fm = [NSFileManager defaultManager];
	
	return [fm fileExistsAtPath:appDirectoryPath];

}

- (IBAction) editInterface:(id)sender {
	//NSLog(@"default = %@", [self selectedApplication].defaultImplementation);
	[defaultImplementationField setStringValue:[self selectedApplication].defaultImplementation];
	[interfaceCreatorWindow makeKeyAndOrderFront:self];
}

- (IBAction) saveInterface:(id)sender {
	Application *app = [self selectedApplication];

	NSString *scriptDirectory = [[NSUserDefaults standardUserDefaults] stringForKey:@"PathToScripts"];
	NSString *applicationPath = [NSString stringWithFormat:@"%@%@", scriptDirectory, app.name];
	
	// CREATE INTERFACE FILE
	NSMutableString *interfaceFile = [NSMutableString stringWithFormat:@"properties = {\n\tdefaultImplementation = \"%@\"\n}\n\nfunctionalities = {",[self selectedApplication].defaultImplementation];
	for(Functionality *f in app.functionalities) {
		NSMutableString *funcString = [NSMutableString stringWithFormat:@"\n\t{name = \"%@\", destination = \"%@\", min = %f, max = %f},",
									   f.name,
									   f.destination,
									   f.min,
									   f.max];
		[interfaceFile appendString:funcString];
	}
	[interfaceFile appendString:@"\n}"];
	
	[interfaceFile appendString:app.postFunctionalitiesInterfaceCode];
	NSString *interfacePath = [NSString stringWithFormat:@"%@/Interface.lua",applicationPath];

	NSError *error;
	[interfaceFile writeToFile:interfacePath atomically:YES encoding:1 error:&error];
	
	[app refreshInterface];
	[app refreshImplementation];
}

- (IBAction) newFunctionality:(id)sender {
	[[self selectedApplication] addFunctionality];
}

- (IBAction) refreshInterface:(id)sender {
	[[self selectedApplication] refreshInterface];
}

- (IBAction) refreshImplementation:(id)sender{
	[[self selectedApplication] refreshImplementation];
}

- (IBAction) newMapping:(id)sender {
	[[self selectedApplication] addNewMapping];
}

- (void) applicationIsSoloing:(Application *)app {
	if(app.solo == YES) {
		self.isSoloing = YES;
	}else{
		for(Application *a in applications) {
			if(a.solo == YES) return;			// if something else is soloing leave the isSoloing flag set to true
		}
		self.isSoloing = NO;
	}
}

- (void)addApplicationWithName:(char *)name ipAddress:(char *)ip port:(int)port {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL shouldAdd = YES;
	Application *a = [[Application alloc] initWithName:name ipAddress:ip port:port];
	
	for(Application *_a in applications)
		if([a isEqual:_a]) shouldAdd = NO;
	
	if(shouldAdd) {
		[self willChangeValueForKey:@"applications"];
		[applications addObject:a];
		[self didChangeValueForKey:@"applications"];
		
		[a readMappings];
		a.chosenScript = (a.defaultImplementation != nil) ? a.defaultImplementation : @"Default.lua";
	}
	
	[a release];
	[pool release];
}

- (void)removeApplicationWithName:(NSString *)name {
	[self willChangeValueForKey:@"applications"];	
	[applications removeObject:[self applicationWithName:name]];
	[self didChangeValueForKey:@"applications"];	
}

- (Application *)applicationWithName:(NSString *)name {
	for(Application *a in applications) {
		if([a.name isEqualToString:name]) return a;
	}
	return nil;
}

- (Application *) selectedApplication {
	return [applications objectAtIndex:[applicationsTableView selectedRow]];
}

- (IBAction)forceDisconnectApplication:(id)sender {
	[self willChangeValueForKey:@"applications"];
	[applications removeObjectAtIndex:[applicationsTableView selectedRow]];
	[self didChangeValueForKey:@"applications"];
}

- (void) sendApplicationsValue:(float)value fromControlWithID:(int)controlID onDevice:(Device *)device {
	for(Application *app in applications) {
		[app processValue:value fromControlWithID:controlID onDevice:device];
	}

	int deviceID = device.deviceID;
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:FLOAT(value), @"value", INT(controlID), @"controlID", INT(deviceID), @"deviceID", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"control message" object:nil userInfo:dict];
}

- (void) sendApplicationsValue:(float)value fromControlWithID:(int)controlID onDeviceWithID:(int)deviceID {
	// TODO: only the device id is required not the entire device; change all code to use this so Record works correctly.
	for(Application *app in applications) {
		[app processValue:value fromControlWithID:controlID onDeviceWithID:deviceID];
	}
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:FLOAT(value), @"value", INT(controlID), @"controlID", INT(deviceID), @"deviceID", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"control message" object:nil userInfo:dict];
	
}


- (void) sendApplicationsValues:(NSArray *)values fromControlWithID:(int)controlID onDevice:(Device *)device {
	for(Application *app in applications) {
		[app processValues:values fromControlWithID:controlID onDevice:device];
	}
}
-(void)tableView: (NSTableView*)inTableView mouseDownInHeaderOfTableColumn:(NSTableColumn*)tableColumn {
	[inTableView setAllowsColumnReordering:NO];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	if([applicationsTableView selectedRow] != -1) {
		NSMutableArray *mappings = [self selectedApplication].mappings;
		Mapping *mappingForRow = [mappings objectAtIndex:rowIndex];
		//NSLog(@"%@ :: deviceConnected %d", [mappingForRow description], mappingForRow.isDeviceConnected);
		if([[aTableColumn identifier] intValue] == 1) {
			if(mappingForRow.isConnected && mappingForRow.isDeviceConnected && !mappingForRow.isDynamic) {
				[((NSPopUpButtonCell *)aCell) setBackgroundColor: [NSColor controlBackgroundColor]];
			}else if(!mappingForRow.isDeviceConnected) {
				[((NSPopUpButtonCell *)aCell) setBackgroundColor:  [NSColor redColor]];
			}else if(mappingForRow.isDynamic) {
				[((NSPopUpButtonCell *)aCell) setBackgroundColor:  [NSColor purpleColor]];
			}else{
				[((NSPopUpButtonCell *)aCell) setBackgroundColor:  [NSColor yellowColor]];
			}
		}
	}
}

- (IBAction) createNewApplication:(id)sender {
	// CREATE APP
	NSString *appName = [applicationNameField stringValue];
	Application *a = [[Application alloc] initWithName:(char *)[appName UTF8String] ipAddress:"127.0.0.1" port:10001];
	
	// CREATE DIRECTORY FOR APPLICATION
	NSString *scriptDirectory = [[NSUserDefaults standardUserDefaults] stringForKey:@"PathToScripts"];
	NSString *applicationPath = [NSString stringWithFormat:@"%@%@", scriptDirectory, appName];
	
	NSFileManager *filemgr;
	filemgr = [NSFileManager defaultManager];
	[filemgr createDirectoryAtPath:applicationPath withIntermediateDirectories:NO attributes:nil error:nil];
	
	// CREATE INTERFACE FILE
	NSMutableString *interfaceFile = [NSMutableString stringWithString:@"properties = {\n\tdefaultImplementation = \"Default.lua\"\n}\n\nfunctionalities = {\n\t{ name=\"X\", destination=\"/X\", min = -1, max = 1 },\n} "];
	NSString *interfacePath = [NSString stringWithFormat:@"%@/Interface.lua",applicationPath];

	NSError *error;
	[interfaceFile writeToFile:interfacePath atomically:YES encoding:1 error:&error];
	
	[a refreshInterface];
	//NSLog([a.functionalities description]);
	// ADD ONE DEFAULT MAPPING
	[a addNewMapping];
	
	// CREATE IMPLEMENTATION FILE
	NSMutableString *implementationFile = [NSMutableString stringWithString:[ds.luaManager saveLuaFileForApp:a]];
	NSString *implementationPath = [NSString stringWithFormat:@"%@/Default.lua", applicationPath];	

	[implementationFile writeToFile:implementationPath atomically:YES encoding:1 error:&error];

	// LOAD IMPLEMENTATION FILE
	a.chosenScript = [NSMutableString stringWithString:@"Default.lua"];
	[self willChangeValueForKey:@"applications"];
	[applications addObject:a];
	[self didChangeValueForKey:@"applications"];
	
	[applicationCreatorWindow close];
}

- (IBAction) launchNewApplicationWindow:(id)sender {
	[applicationCreatorWindow makeKeyAndOrderFront:self];
	
}
- (void) dealloc {
	[applications release];
	[super dealloc];
}

@end

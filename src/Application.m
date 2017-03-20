//
//  Application.m
//  DeviceServer_1
//
//  Created by charlie on 11/5/08.


#import "Application.h"
#import "Device.h"
#import "OSCManager.h"
#import "Mapping.h"
#import "Functionality.h"

@implementation Application

@synthesize name, scripts, chosenScript, polling, mappings, ipAddress, port, defaultImplementation, lua, solo, isSoloing, functionalities, 
postFunctionalitiesInterfaceCode, preFunctionalitiesInterfaceCode, postMappingsImplementationCode, preMappingsImplementationCode, address, mute;

- (id)initWithName:(char *)aName ipAddress:(char *)aIpAddress port:(int)aPort {
	if (self = [super init]) {
		ds = [NSApp delegate];
		
		name = [[[NSString alloc] initWithCString:aName encoding:1] retain];
		ipAddress = [[[NSString alloc] initWithCString:aIpAddress encoding:1] retain];
		port = aPort;
        
        mute = NO;
		
		address  = lo_address_new([ipAddress UTF8String], [[INT(port) stringValue] UTF8String]);
		
		scripts = [NSMutableArray arrayWithArray:[ds.luaManager scriptNamesForApplicationNamed:name]];
		[scripts retain];

		polling = NO;
		mappings = [[NSMutableArray alloc] init];
		functionalities = [[NSMutableArray alloc] init];
		[self initializeLua];
		[self addObserver:self forKeyPath:@"chosenScript" options:NSKeyValueObservingOptionNew context:NULL];
		[self addObserver:self forKeyPath:@"solo" options:NSKeyValueObservingOptionNew context:NULL];
	}
	
	return self;
}

- (void) addFunctionality {
	Functionality *f = [[Functionality alloc] init];
	f.name = @"__NAME__";
	f.destination = @"/destination";
	f.min = -1;
	f.max = 1;
	[self willChangeValueForKey:@"functionalities"];
	[functionalities addObject:f];
	[self didChangeValueForKey:@"functionalities"];	
}

- (void) addNewMapping {
//	/*NSString *mappingName = /*([self.mappings count] > 0) ? ((Mapping *)[self.mappings objectAtIndex:0]).name : */ @"X";
//	NSString *destination = /*([self.mappings count] > 0) ? ((Mapping *)[self.mappings objectAtIndex:0]).destination :*/ @"/X";
//	NSNumber *min		  = /*([self.mappings count] > 0) ? FLOAT(((Mapping *)[self.mappings objectAtIndex:0]).min) : */FLOAT(-1);
//    NSNumber *max		  = /*([self.mappings count] > 0) ? FLOAT(((Mapping *)[self.mappings objectAtIndex:0]).max) :*/FLOAT(1);
//	
//	NSDictionary *mappingProperties = [NSDictionary dictionaryWithObjectsAndKeys:mappingName, @"name", min, @"min", max, @"max", destination, @"destination", nil];
	Mapping *m = [[Mapping alloc] initWithFunctionality:[functionalities objectAtIndex:0]];
	DeviceManager *dm  = ds.dm;
	m.deviceName = ([dm.connectedDevices count] > 0) ?  ((Device *)[dm.connectedDevices objectAtIndex:0]).displayName : @"Trackpad";
	m.controlName = ([dm.connectedDevices count] > 0) ? [[((Device *)[dm.connectedDevices objectAtIndex:0]).controls objectAtIndex:0] objectForKey:@"name"] : @"X";
	m.expression = @"";
	m.application = self;
	

	[self willChangeValueForKey:@"mappings"];
	[self registerMapping:m];	
	[self didChangeValueForKey:@"mappings"];
}

- (void) runBuffer:(NSString*)buf {
    
    // oh geeze, don't tell anyone i'm using threadDictionary!
    //[[[NSThread currentThread] threadDictionary] setObject:[NSNumber numberWithBool:YES] forKey:LCRunningInLuaKey];
    
    if (luaL_loadbuffer(lua.luaState, [buf UTF8String], [buf length], nil) || lua_pcall(lua.luaState, 0, 0, 0)) {
        [self error:"Error: %s\n", lua_tostring(lua.luaState, -1)];
    }
    
    //[[[NSThread currentThread] threadDictionary] removeObjectForKey:LCRunningInLuaKey];
}
- (void) pushAsLuaString:(NSString*)s withName:(NSString*)name {
    lua_pushstring(lua.luaState, [name UTF8String]);
    lua_pushstring(lua.luaState, [s UTF8String]);
    lua_settable(lua.luaState, LUA_GLOBALSINDEX);
}
- (id) objectNamed:(NSString*)_name {
    
    lua_getglobal(lua.luaState, [_name UTF8String]);
    
    //id ret = lua_objc_topropertylist(lua.luaState, -1);
	id ret = LuaCocoa_ToPropertyList(lua.luaState, -1);
    
    if (ret == [NSNull null]) {
        return nil;
    }
    
    return ret;
}

- (void) initializeLua {
	lua = [[LuaCocoa alloc] init];

	
	//luaJIT_setmode([lua state], 0, LUAJIT_MODE_ON);
	
	scriptDirectory = (NSMutableString *)[[NSUserDefaults standardUserDefaults] stringForKey:@"PathToScripts"];
	[scriptDirectory retain];

	//if(scriptDirectory == nil) scriptDirectory = [NSMutableString stringWithString:@"~/Documents/Allosphere/Device Server Scripts/"];
	
	//[lua pushGlobalObject:ds.console withName:@"console"];
	LuaCocoa_PushInstance(lua.luaState, ds.console);
	lua_setglobal(lua.luaState, "console");

	//[lua pushGlobalObject:self withName:@"application"];
	LuaCocoa_PushInstance(lua.luaState, self);
	lua_setglobal(lua.luaState, "application");

	//[lua runBuffer:@"print(jit.version)"];
	
	[self runBuffer:@"DNR = DNR_NUMBER"];
	[self runBuffer:@"console.print = console.print_"];	
	//[lua runBuffer:@"DNR = DNR_NUMBER"];	
	//[lua runBuffer:@"console.print = console.print_"];
}

- (void) mappingIsSoloing:(Mapping *)mapping {
	if(mapping.solo == YES) {
		self.isSoloing = YES;
	}else{
		for(Mapping *m in mappings) {
			if(m.solo == YES) return;			// if something else is soloing leave the isSoloing flag set to true
		}
		self.isSoloing = NO;
	}
}

- (NSArray *) getMappingsForScriptNamed:(NSString *)scriptName {
	NSUserDefaults *std = [NSUserDefaults standardUserDefaults];
	
	NSMutableString *scriptPath = [NSMutableString stringWithString:[std stringForKey:@"PathToScripts"]];
	[scriptPath appendString:name];
	[scriptPath appendString:@"/"];
	[self pushAsLuaString:scriptPath withName:@"gPwd"];
	
	[scriptPath appendString:scriptName];
	
	NSMutableString *cmd = [NSMutableString stringWithFormat:@"dofile(\"%@\")", scriptPath];
	[self runBuffer:cmd];
	
	NSArray *_mappings = [self objectNamed:@"mappings"];
	
	NSString *fullFile = [NSString stringWithContentsOfFile:scriptPath encoding:1 error:nil];
	NSScanner *scan = [NSScanner scannerWithString:fullFile];
	
	if(preMappingsImplementationCode != nil)
		[preMappingsImplementationCode release];
	
	[scan scanUpToString:@"mappings" intoString:&preMappingsImplementationCode];
	[preMappingsImplementationCode retain];
	
	//int start = [scan scanLocation];
	
	[scan scanUpToString:@"{" intoString:NULL];
	[scan setScanLocation:[scan scanLocation] + 1];
	
	NSCharacterSet *brackets = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
	
	int depth = 1;
	
	while(depth > 0 && ![scan isAtEnd]) {
		NSString *holder;
		[scan scanUpToCharactersFromSet:brackets intoString:&holder];
		[scan setScanLocation:[scan scanLocation] + 1];
		unichar letter = [fullFile characterAtIndex:[scan scanLocation]-1]; 
		if(letter == '{')
			depth++;
		else if(letter == '}')
			depth--;
	}
	
	int end = [scan scanLocation];
	
	if(postMappingsImplementationCode != nil)
		[postMappingsImplementationCode release];
	
	postMappingsImplementationCode = [fullFile substringWithRange:NSMakeRange(end, [fullFile length] - end)];
	[postMappingsImplementationCode retain];
	
	return _mappings;
}


- (void) readFunctionalities {
	NSUserDefaults *std = [NSUserDefaults standardUserDefaults];
	
	NSMutableString *scriptPath = [NSMutableString stringWithString:[std stringForKey:@"PathToScripts"]];
	[scriptPath appendString:[NSString stringWithFormat:@"%@/Interface.lua",name]];
	
	NSString *fullFile = [NSString stringWithContentsOfFile:scriptPath encoding:1 error:nil];
	
	NSMutableString *cmd = [NSMutableString stringWithFormat:@"dofile(\"%@\")", scriptPath];
	[self runBuffer:cmd];
	NSArray *_functionalities = ([self objectNamed:@"functionalities"] != nil) ? [self objectNamed:@"functionalities"] : [self objectNamed:@"signals"];

	for(NSDictionary * d in _functionalities) {
		Functionality *f = [[Functionality alloc] init];
		f.name = [d objectForKey:@"name"];
		f.destination = [d objectForKey:@"destination"];
		f.min = [[d objectForKey:@"min"] floatValue];
		f.max = [[d objectForKey:@"max"] floatValue];
		
		[self willChangeValueForKey:@"functionalities"];
		[functionalities addObject:f];
		[self didChangeValueForKey:@"functionalities"];		
		[f release];
	}
	
	NSScanner *scan = [NSScanner scannerWithString:fullFile];
	
	if(preFunctionalitiesInterfaceCode != nil)
		[preFunctionalitiesInterfaceCode release];

	[scan scanUpToString:@"functionalities" intoString:&preFunctionalitiesInterfaceCode];
	[preFunctionalitiesInterfaceCode retain];
	
	[scan scanUpToString:@"{" intoString:NULL];
	[scan setScanLocation:[scan scanLocation] + 1];
	
	NSCharacterSet *brackets = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
	
	int depth = 1;
	
	while(depth > 0 && ![scan isAtEnd]) {
		NSString *holder;
		[scan scanUpToCharactersFromSet:brackets intoString:&holder];
		[scan setScanLocation:[scan scanLocation] + 1];
		unichar letter = [fullFile characterAtIndex:[scan scanLocation]-1]; 
		if(letter == '{')
			depth++;
		else if(letter == '}')
			depth--;
	}
	
	int end = [scan scanLocation];
	
	if(postFunctionalitiesInterfaceCode != nil)
		[postFunctionalitiesInterfaceCode release];
	
	postFunctionalitiesInterfaceCode = [fullFile substringWithRange:NSMakeRange(end, [fullFile length] - end)];
	[postFunctionalitiesInterfaceCode retain];
	
	NSDictionary *properties = [self objectNamed:@"properties"];
	
	if(properties != nil && [properties isKindOfClass:[NSDictionary class]]) {
		/*
		if(self.defaultImplementation != nil) {
			[self.defaultImplementation release];
		}
		*/
		self.defaultImplementation = [NSMutableString stringWithString:[properties objectForKey:@"defaultImplementation"]];
	}
	
	/*for(Functionality *f in functionalities) {
		NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:f.name, @"name", f.destination, @"destination", FLOAT(f.min), @"min", FLOAT(f.max), @"max", nil];
		Mapping *m = [[Mapping alloc] initWithProperties:d];				
		[self registerMapping:m];
	}*/
}


- (void) outputMessageWithAddress:(NSString *)oscAddress value:(float)value {
	for(Mapping *m in mappings) {
		if([m.destination isEqualToString:oscAddress]) { // max, min, expectedMax, expectedMin
			float transformedValue;
			BOOL isPitch = [oscAddress isEqualToString:@"/pitch"];
			
			float deviceRange = fabs(m.min - m.max); //  = +1
			if(isPitch) NSLog(@"min = %f, max = %f, deviceRange = %f", m.min, m.max, deviceRange);
			
			float appRange = fabs(m.expectedMin - m.expectedMax); // +8
			if(isPitch) NSLog(@"expectedMin = %f, expectedMax = %f, appRange = %f", m.expectedMin, m.expectedMax, appRange);
			
			float percentOfAppRange = fabs(value - m.expectedMin) / appRange; // fabs(-3 - -4) = 1 / 8 = .125
			if(isPitch) NSLog(@"value = %f, m.expectedMin = %f, perecentOfAppRange = %f", value, m.expectedMin, percentOfAppRange);

			transformedValue = m.min + (percentOfAppRange * deviceRange); // 0 + .875 * 1 = .875
			if(isPitch) NSLog(@"m.min:%f + (percentOfAppRange :%f * deviceRange:%f) = transformedValue:%f",m.min, percentOfAppRange, deviceRange, transformedValue);
			[m.device outputValue:transformedValue forControl:m.controlID];
			
			break;
		}
	}
}

- (void) readMappings {
	[self willChangeValueForKey:@"mappings"];
	[self readFunctionalities];
	[self didChangeValueForKey:@"mappings"];
}

- (void) refreshInterface {
	NSUserDefaults *std = [NSUserDefaults standardUserDefaults];
	
	NSMutableString *scriptPath = [NSMutableString stringWithString:[std stringForKey:@"PathToScripts"]];
	[scriptPath appendString:[NSString stringWithFormat:@"%@/Interface.lua",name]];
	
	NSMutableString *cmd = [NSMutableString stringWithFormat:@"dofile(\"%@\")", scriptPath];
	[self runBuffer:cmd];
	
	if([functionalities count] > 0) [functionalities removeAllObjects];
	
	NSArray *_functionalities = ([self objectNamed:@"functionalities"] != nil) ? [self objectNamed:@"functionalities"] : [self objectNamed:@"signals"];
	
	for(NSDictionary * d in _functionalities) {
		Functionality *f = [[Functionality alloc] init];
		f.name = [d objectForKey:@"name"];
		f.destination = [d objectForKey:@"destination"];
		f.min = [[d objectForKey:@"min"] floatValue];
		f.max = [[d objectForKey:@"max"] floatValue];
		
		[self willChangeValueForKey:@"functionalities"];
		[functionalities addObject:f];
		[self didChangeValueForKey:@"functionalities"];		
		[f release];
	}
	
	[self willChangeValueForKey:@"mappings"];

	Mapping *foundMapping = nil;
	for(Functionality *f in functionalities) {
		BOOL shouldAdd = NO;
		
		for(Mapping *m in self.mappings) {
			if([m.name isEqualToString:f.name]) {
				shouldAdd = NO;
				foundMapping = m;
				break;
			}
		}
		// TODO: RENAME EXPECTEDMIN AND EXPECTEDMAX / MIN AND MAX FOR MAPPINGS
		if(shouldAdd) {
			Mapping *_m = [[Mapping alloc] initWithFunctionality:f];
			_m.isConnected = NO;
			[self registerMapping:_m];
		}else{
			if(foundMapping.expectedMin != f.min) foundMapping.expectedMin = f.min;
			if(foundMapping.expectedMax != f.max) foundMapping.expectedMax = f.max;
			//if(![foundMapping.destination isEqualToString:f.destination]) foundMapping.destination = f.destination;	
			float range;
			if(foundMapping.min >= 0) {
				foundMapping.offset = 0;
				range = foundMapping.max - foundMapping.min;
			} else {
				range = (foundMapping.max - foundMapping.min);
				foundMapping.offset = 0 - foundMapping.min;
			}
			float expectedRange = foundMapping.expectedMax - foundMapping.expectedMin;
			foundMapping.scalar = expectedRange / range;
		}
	}
	
	for(Mapping *m in self.mappings) {
		BOOL isFound = NO;
		for(NSDictionary * dict in functionalities) {
			if([m.name isEqualToString:[dict objectForKey:@"name"]]) {
				isFound = YES;
			}
		}
		if(!isFound) {
			[self.mappings removeObject:m];
		}
	}
	
	[self didChangeValueForKey:@"mappings"];

}

- (void) refreshImplementation {
	[self readScript:[self chosenScript]];
}

- (Mapping *) mappingWithProperties:(NSDictionary *)dict {
	Mapping *goal = nil;
	for(Mapping *m in self.mappings) {
		if(![m.name isEqualToString:[dict objectForKey:@"name"]]) continue;
		
		if([[dict objectForKey:@"device"] isKindOfClass:[NSString class]]) {
			if([ds.dm deviceIDforName:[dict objectForKey:@"device"]] != m.deviceID) continue;
		}else{
			if([[dict objectForKey:@"device"] intValue] != m.deviceID) continue;
		}
		
		if([[dict objectForKey:@"control"] isKindOfClass:[NSString class]]) {
			if([ds.dm deviceIDforName:[dict objectForKey:@"control"]] != m.controlID) continue;
		}else{
			if([[dict objectForKey:@"control"] intValue] != m.controlID) continue;
		}
		
		goal = m;
	}
	
	return goal;
}

- (Functionality *) functionalityWithName:(NSString *)functionalityName {
	for(Functionality *f in functionalities) {
		if([f.name isEqualToString:functionalityName]) {
			return f;
		}
	}
	return nil;
}

- (void) readScript:(NSString *)scriptName {
	[self willChangeValueForKey:@"mappings"];
	
	[mappings removeAllObjects];
	[functionalities removeAllObjects];
	[self readFunctionalities];
	
	NSArray *maps = [self getMappingsForScriptNamed:scriptName];
	
	for(NSDictionary *dict in maps) {
		Functionality *f = [self functionalityWithName:[dict objectForKey:@"name"]];
		if(f == nil) {
			NSString *mappingName = [dict objectForKey:@"name"];
			[ds.console print:[NSString stringWithFormat:@"WARNING: mapping for %@ found in implementation but does not in interface", mappingName]];
			continue;
		}

		Mapping *m = [[Mapping alloc] initWithFunctionality:f];
		m.application = self;
		
		if(m.destination == nil) m.destination = [dict objectForKey:@"destination"];

		if([[dict objectForKey:@"device"] isKindOfClass:[NSString class]]) {
			m.deviceID = [ds.dm deviceIDforName:[dict objectForKey:@"device"]];
		}else{
			m.deviceID = [[dict objectForKey:@"device"] intValue];		// change this one
		}

		m.deviceName = [[NSMutableString alloc] initWithString:[ds.dm deviceNameForID:m.deviceID]];		
		if([dict objectForKey:@"expression"] != nil) {
			m.expression = [dict objectForKey:@"expression"];
		}
		
		if(m.expression != nil) {
			if(![m.expression isEqual:@""]) {
				lua_State * L = m.application.lua.luaState;
				lua_pushstring(L, [m.expression UTF8String]);	// push string representing expression
				lua_setglobal(L, "expr");						// give name to value on stack
				if([m.expression characterAtIndex:0] == 'x') {
					luaL_dostring(L, "return loadstring('return function(x, rawx, mapping) ' .. expr .. ' return x end ')()");	 // get a function
				}else{
					luaL_dostring(L, "return loadstring('return function(x, rawx, mapping) ' .. expr .. ' return y end ')()");	 // get a function
				}
				m.expressionID = luaL_ref(L, LUA_REGISTRYINDEX);	// push it into the registryindex table and store an id in the table that refers to function
			}
		}else{
			//m.expression = @"";
		}
		
		m.cID = ([dict objectForKey:@"cID"] != nil) ? (int)[[dict objectForKey:@"cID"] intValue] : NO_CONTROL_ID;
		m.polling = NO;
		
		m.device = [ds.dm deviceForID:m.deviceID];
		
		if(m.device != nil) {		// if device is currently connected
			m.isDeviceConnected  = YES;
		} else {
			m.isDeviceConnected = NO;
			m.device = [ds.dm dummyDeviceForID:m.deviceID];
		}
		
		if([[dict objectForKey:@"control"] isKindOfClass:[NSString class]]) {
			m.controlName = [dict objectForKey:@"control"];
			@try {
				m.controlID = [m.device controlIDForName:m.controlName];
			}@catch (id theException) {
				[ds.console print:[NSString stringWithFormat:@"ERROR: Cannot find device description for %@", m.device.name]];
			}
		}else{
			m.controlID = [[dict objectForKey:@"control"] intValue]; 
			@try {
				m.controlName = [m.device controlNameForControlID:m.controlID];
			}@catch (id theException) {
				[ds.console print:[NSString stringWithFormat:@"ERROR: Cannot find device description for %@", m.device.name]];
			}
		}
		// must be after device since that triggers KVO and initializes controlID
		NSMutableDictionary *props = [ds.luaManager controlPropertiesForControlWithID:m.controlID onDeviceWithID:m.deviceID];
		m.min = [[props objectForKey:@"minimum"] intValue];
		m.max = [[props objectForKey:@"maximum"] intValue];
		m.luaExpression = [props objectForKey:@"expression"];
		m.usagePage = [[props objectForKey:@"usagePage"] intValue];
		m.usage = [[props objectForKey:@"usage"] intValue];
		m.isConnected = YES;

		
		float range;
		if(m.min >= 0) {
			m.offset = 0;
			range = m.max - m.min;
		} else {
			range = (m.max - m.min);
			m.offset = 0 - m.min;
		}
		
		float expectedRange = m.expectedMax - m.expectedMin;
		m.scalar = expectedRange / range;

		[mappings addObject:m];
		[m release];
	}

	[self didChangeValueForKey:@"mappings"];
}

- (void) addScript:(NSString *)scriptName {
	[self willChangeValueForKey:@"scripts"];
	[scripts addObject:scriptName];
	[self didChangeValueForKey:@"scripts"];
}

- (Mapping *) mappingForName:(NSString *)mappingName {
	for(Mapping *m in mappings) {
		if([m.name isEqualToString:mappingName]) {
			return m;
		}
	}
	return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {	
	if([keyPath isEqual:@"chosenScript"]) {
		[chosenScript release];
		chosenScript = [NSMutableString stringWithString:[change objectForKey:@"new"]];
		[chosenScript retain];
		[self readScript:chosenScript];
		[ds.console print:[NSString stringWithFormat:@"reading script %@ for application %@", chosenScript, name, nil]];
		return;
	}else if([keyPath isEqual:@"solo"]) {
		[ds.am applicationIsSoloing:self];
		return;
	}else if([keyPath isEqual:@"ipAddress"]) {
		if(address != NULL)
			lo_address_free(address);
		
		address  = lo_address_new([ipAddress UTF8String], [[INT(port) stringValue] UTF8String]);
		return;
	}else if([keyPath isEqual:@"port"]) {
		if(address != NULL)
			lo_address_free(address);
		
		address  = lo_address_new([ipAddress UTF8String], [[INT(port) stringValue] UTF8String]);
		return;
	}

	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (BOOL)isEqual:(id)anObject {
	BOOL result = NO;
	Application *app = (Application *)anObject;
	
	result = ([name isEqualToString:app.name] && port == app.port && [ipAddress isEqualToString:app.ipAddress]);
	
	return result;
}

- (void)registerMapping:(Mapping *)mapping {
	//if(![mappings containsObject:mapping]) { 
		[mappings addObject:mapping];
		//[ds.console print:[NSString stringWithFormat:@"added control :: %@ from device %@", control.name, control.device.name]];
	//}
}	

- (void)unregisterMapping:(Mapping *)mapping {
	if([mappings containsObject:mapping]) {
		//[ds.console print:[NSString stringWithFormat:@"removing control :: %@ from device %@", control.name, control.device.name]];		
		[mappings removeObject:mapping];
	}
}

- (void) processValue:(float)value fromControlWithID:(int)controlID onDevice:(Device *)device {
	if((self.solo || !ds.am.isSoloing) && !self.mute ) {
		for(Mapping *mapping in mappings) {
			if(mapping.isConnected) {
				//[ds.console print:[NSString stringWithFormat:@"%d :: %d :: %d :: %d",  device.deviceID, mapping.deviceID, controlID, mapping.controlID]];		

				if(device.deviceID == mapping.deviceID && controlID == mapping.controlID) {
					if(polling)
						[ds.console print:[NSString stringWithFormat:@"%@ :: %@ :: %@ :: %f", name, device.name, mapping.name, value]];		
					[mapping sendValue:value toApp:self];
				}
			}
		}
	}
}

//- (void) processValue:(float)value fromControlWithID:(int)controlID onDeviceWithID:(int)deviceID {
//	for(Mapping *mapping in mappings) {
//		if(mapping.isConnected) {
//			if(deviceID == mapping.deviceID && controlID == mapping.controlID) {
//				//if(polling)
//				//	[ds.console print:[NSString stringWithFormat:@"%@ :: %@ :: %@ :: %f", name, device.name, mapping.name, value]];
//				[mapping sendValue:value toApp:self];
//			}
//		}
//	}
//}

- (void) processValues:(NSArray *)values fromControlWithID:(int)controlID onDevice:(Device *)device {
	if(self.solo || !ds.am.isSoloing) {
		for(Mapping *mapping in mappings) {
			if(mapping.isConnected) {
				if(device.deviceID == mapping.deviceID && controlID == mapping.controlID) {
					[mapping sendValues:values toApp:self];
					if(polling) {
						[ds.console print:[NSString stringWithFormat:@"%@ :: %@ :: %@ :: %@",
										   name, device.name, mapping.name, [[values description] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
					}
				}
			}
		}
	}
}

- (void) addDynamicControlWithName:(NSString *)controlName
					   destination:(NSString *)destination
					  deviceNumber:(int)deviceNumber
					 controlNumber:(int)controlnumber
					   expectedMin:(float)expectedMin
					   expectedMax:(float)expectedMax
						expression:(NSString *)expression
							   cID:(int)cID {

	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:controlName, @"name",
						  [NSNumber numberWithFloat:expectedMin], @"min",
						  [NSNumber numberWithFloat:expectedMax], @"max", nil];
	
	[self willChangeValueForKey:@"mappings"];
	Mapping *m = [[Mapping alloc] initWithProperties:dict];
	[mappings addObject:m];

	m.isDynamic = YES;
	m.destination = destination;
	m.deviceID = deviceNumber;
	m.device = [ds.dm deviceForID:m.deviceID];
		
	m.deviceName = m.device.displayName;
	m.controlID = controlnumber;
	m.controlName = [m.device controlNameForControlID:m.controlID];	

	NSMutableDictionary *props = [ds.luaManager controlPropertiesForControlWithID:m.controlID onDeviceWithID:m.device.deviceID];

	m.min = [[props objectForKey:@"minimum"] intValue];
	m.max = [[props objectForKey:@"maximum"] intValue];
	m.luaExpression = [props objectForKey:@"expression"];
	m.usagePage = [[props objectForKey:@"usagePage"] intValue];
	m.usage = [[props objectForKey:@"usage"] intValue];	
	m.isConnected = YES;
	m.expression = expression;
	m.cID = cID;
	
	[self didChangeValueForKey:@"mappings"];
	[m release];
}

- (void) sendValue:(float)value forMapping:(Mapping *)mapping {
	[ds.osc sendValue:value forMapping:(Mapping *)mapping toApp:(Application *)self];
	//[ds.osc sendValue:value toDestination:mapping.destination atIPAddress:ipAddress port:port cID:mapping.cID];
	if(polling)
		[ds.console print:[NSString stringWithFormat:@"%@ :: %@ :: %@ :: %f", name, mapping.device.name, mapping.name, value]];		
}

- (void) clearLuaStack {
	lua_State *L = lua.luaState;
	lua_settop(L,0);
}

- (void)dealloc {
	lo_address_free(address);
	[preFunctionalitiesInterfaceCode release];
	[postFunctionalitiesInterfaceCode release];	
	[lua release];
	[chosenScript release];
	[name release];
	[ipAddress release];
	[scripts release];
	[functionalities release];	
	[mappings release];
	[super dealloc];
}

@end

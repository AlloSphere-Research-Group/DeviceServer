//
//  Mapping.m
//  DeviceServer_1
//
//  Created by charlie on 11/6/08.


#import "Mapping.h"
#import "Device.h"
#import "OSCManager.h"
#import "Application.h"
#import "Functionality.h"

#define MAX_VALUE_STORAGE 50

@implementation Mapping
@synthesize name, usagePage, usage, device, deviceName, destination, expression, luaExpression, cID, polling, deviceID, min, max, isDynamic,
controlID, expectedMin, expectedMax, scalar, isConnected, isDeviceConnected, dictionary, output, value, controlName, rawX, offset, application, preExpressionValue,
deviceRange, expectedRange, expressionID, solo, ds;

- (id) initWithProperties:(NSDictionary *)props {
	if (self = [super init]) {
		ds = [NSApp delegate];

		output = [[NSMutableArray alloc] init];

		name = [props objectForKey:@"name"];
		[name retain];
//		NSLog([props description]);
		expectedMin = [[props objectForKey:@"min"] floatValue];
		expectedMax = [[props objectForKey:@"max"] floatValue];
		
		cID = NO_CONTROL_ID;
				
		if([props objectForKey:@"destination"] != NULL) { // check in case destination is in implementation file
			self.destination = [props objectForKey:@"destination"];
		}else{
			destination = NULL;							  // if this is NULL the destination will be set when the implementation is read in
		}
		
		isDeviceConnected = NO;	// assume yes until proven otherwise when script is loaded
		isDynamic = NO;				// assume no
		
		[self addObserver:self forKeyPath:@"controlName"	options:NSKeyValueObservingOptionNew context:NULL];
		[self addObserver:self forKeyPath:@"name"			options:NSKeyValueObservingOptionNew context:NULL];		
		[self addObserver:self forKeyPath:@"deviceName"		options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
		[self addObserver:self forKeyPath:@"expression"		options:NSKeyValueObservingOptionNew context:NULL];
		[self addObserver:self forKeyPath:@"solo"			options:NSKeyValueObservingOptionNew context:NULL];
		[self addObserver:self forKeyPath:@"isDeviceConnected" options:NSKeyValueObservingOptionNew context:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkConnectionForNewDevice:) name:@"New Device" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkExistingConnectionsForDeviceRemoval:) name:@"Device Removed" object:nil];
	}
	
	return self;
}

- (id) initWithFunctionality:(Functionality *)f {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:f.name, @"name", FLOAT(f.min), @"min", FLOAT(f.max), @"max", f.destination, @"destination",  nil];
	return [self initWithProperties:dict];
}
	
- (void) checkConnectionForNewDevice:(id)notification {
	if(!isDeviceConnected) {
		Device *d = (Device *)[notification object];
		if(d.deviceID == deviceID) { 
			isDeviceConnected = YES;
			self.device = d;
			deviceName = d.name;
			controlName = [self.device controlNameForControlID:self.controlID];
			[ds.controlsTable reloadData];
		}
	}
}

- (void) checkExistingConnectionsForDeviceRemoval:(id)notification {	
	if(isDeviceConnected) {
		Device *d = (Device *)[notification object];
		if(d.deviceID == deviceID) { 
			isDeviceConnected = NO;
			self.device = nil;
			deviceName = nil;
			controlName = nil;
			[ds.controlsTable reloadData];
		}
	}
}

- (Mapping *) copy {
	Mapping *copy = [[Mapping alloc] init];
	copy.output = [[NSMutableArray alloc] init];
	
	copy.usage = usage;
	copy.usagePage = usagePage;
	copy.deviceID = deviceID;
	copy.controlID = controlID;
	copy.cID = cID;
	copy.expressionID = expressionID;
	
	copy.rawX = rawX;
	copy.min = min;
	copy.max = max;
	copy.expectedMin = expectedMin;
	copy.expectedMax = expectedMax;
	copy.deviceRange = deviceRange;
	copy.expectedRange = expectedRange;
	copy.scalar = scalar;
	copy.offset = offset;
	copy.value = value;
	copy.preExpressionValue = preExpressionValue;
	
	copy.controlName = controlName;
	copy.deviceName = deviceName;
	copy.expression = expression;
	copy.luaExpression = luaExpression;
	
	copy.name = [[NSString alloc] initWithString:name];
	copy.destination = [[NSString alloc] initWithString:destination];
	//NSLog(@"copy = %@", copy.destination);
	copy.expectedMin = expectedMin;
	copy.expectedMax = expectedMax;

	copy.application = application;
	copy.device = device;
	
	copy.ds = [NSApp delegate];
		
	isDeviceConnected = NO; // assume yes until proven otherwise when script is loaded
	
	[self addObserver:self forKeyPath:@"controlName" options:NSKeyValueObservingOptionNew context:NULL];
	[self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
	[self addObserver:self forKeyPath:@"deviceName" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
	[self addObserver:self forKeyPath:@"expression" options:NSKeyValueObservingOptionNew context:NULL];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkConnectionForNewDevice:) name:@"New Device" object:nil];
	
	return copy;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	BOOL changeMapping = NO;
	if ([keyPath isEqual:@"name"]) {
		Functionality *f = [application functionalityWithName:[change objectForKey:@"new"]];
		[name release];
		name = f.name;
		expectedMin = f.min;
		expectedMax = f.max;
		[destination release];
		destination = f.destination;
		return;
	}else if ([keyPath isEqual:@"controlName"]) {
		[controlName release];
		controlName = [NSMutableString stringWithString:[change objectForKey:@"new"]];
		[controlName retain];
		controlID = [device controlIDForName:controlName];
		changeMapping = YES;
	}else if([keyPath isEqual:@"deviceName"]) {
		//NSLog(@"old = %@, new = %@", [change objectForKey:NSKeyValueChangeOldKey],[change objectForKey:@"new"]);
		
		if(deviceName != nil)
			[deviceName release];
		
		deviceName = [NSMutableString stringWithString:[change objectForKey:@"new"]];
		[deviceName retain];
		
		[self willChangeValueForKey:@"device"];
		device = [ds.dm deviceForName:deviceName];
		[self didChangeValueForKey:@"device"];
		
		if(device != nil) {
			deviceID = device.deviceID;
			isDeviceConnected = YES;
			[self willChangeValueForKey:@"controlName"];
			[controlName release];
			controlName = [[NSString alloc] initWithString:[device.controlNames objectAtIndex:0]];
			[controlName retain];
			controlID = [device controlIDForName:controlName];
			[self didChangeValueForKey:@"controlName"];			
			changeMapping = YES;
		}else{
			isDeviceConnected = NO;
			return;
		}
	}else if([keyPath isEqual:@"expression"]) {
		//if(expression != NULL)
			//[expression release];
		expression = [[NSMutableString alloc] initWithString:[change objectForKey:@"new"]];
		
		// give name to value on stack
		if([expression length] != 0) {
			lua_State * L = application.lua.luaState;
			lua_pushstring(L, [expression UTF8String]);	// push string representing expression
			lua_setglobal(L, "expr");
			
			int err;
			if([expression characterAtIndex:0] == 'x') {
				err = luaL_dostring(L, "return loadstring('return function(x, rawx, mapping) ' .. expr .. ' return x end ')()");	 // get a function
			}else {
				err = luaL_dostring(L, "return loadstring('return function(x, rawx, mapping) ' .. expr .. ' return y end ')()");	 // get a function
			}
			
			if(!err) {
				[self willChangeValueForKey:@"expressionID"];
				expressionID = luaL_ref(L, LUA_REGISTRYINDEX);
				[self didChangeValueForKey:@"expressionID"];
			}else{
				NSLog(@"error %s", lua_tostring(L, -1));
			}
		}

		return;
	}else if([keyPath isEqual:@"solo"]) {
		[application mappingIsSoloing:self];
		return;
	}else if([keyPath isEqual:@"isDeviceConnected"]) {
		//isDeviceConnected = YES;
		//NSLog(@"device connected = %@", [change objectForKey:@"new"]);
		//NSLog(@"device connected is changing!!!! %@", [self description]);
		return;
	}
	if(changeMapping) {
		@try {
			NSMutableDictionary *dict = [ds.luaManager controlPropertiesForControlWithID:controlID onDeviceWithID:deviceID];
			usage = [[dict objectForKey:@"usage"] intValue];
			usagePage = [[dict objectForKey:@"usagePage"] intValue];
			
			min = [[dict objectForKey:@"minimum"] floatValue];
			max = [[dict objectForKey:@"maximum"] floatValue];
			
			deviceRange = fabs(min - max);
			
			expectedRange = fabs(expectedMin - expectedMax);
			scalar = expectedRange / deviceRange;
			isConnected = YES;
		}
		@catch (id theException) {
			//isDeviceConnected = NO;
		}
		return;
	}
	// YOU MUST RETURN IF YOU'VE HANDLED THE CHANGE MANUALLY IN THE ABOVE CODE SO THAT THE BELOW LINE DOES NOT EXECUTE
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];

}

- (void)setDevice:(int)newDeviceID control:(int)newControlID expression:(NSMutableString *)newExpression cID:(int)newcID {
	if(deviceID != newDeviceID) {
		[self willChangeValueForKey:@"deviceName"];
		deviceID = newDeviceID;
		deviceName = [NSMutableString stringWithString:[ds.dm deviceNameForID:deviceID]];
		[self didChangeValueForKey:@"deviceName"];
		
		[self willChangeValueForKey:@"device"];
		device = [ds.dm deviceForName:deviceName];
		[self didChangeValueForKey:@"device"];
	}
		
	[self willChangeValueForKey:@"controlName"];
	controlName = [device.controlNames objectAtIndex:newControlID];
	[self didChangeValueForKey:@"controlName"];
	
	if(![expression isEqualToString:newExpression]) {
		[self willChangeValueForKey:@"expression"];
		expression = [NSMutableString stringWithString:newExpression];
		[self didChangeValueForKey:@"expression"];
	}
	
	if(newcID != cID) {
		[self willChangeValueForKey:@"cID"];
		cID = newcID;
		[self didChangeValueForKey:@"cID"];
	}
	
}

- (BOOL)isEqual:(id)anObject {
	BOOL result = NO;
	Mapping *mapping = (Mapping *)anObject;

	result = ([name isEqualToString:mapping.name] && [device isEqual: mapping.device] && [controlName isEqualToString:mapping.controlName]);
	
	return result;
}

- (void) storeOutput:(NSNumber *)value {
	[output insertObject:value atIndex:0];
	while([output count] > MAX_VALUE_STORAGE)
		[output removeLastObject];
}

- (void)sendValue:(float)avalue toApp:(Application *)app {
	if(self.solo || !application.isSoloing) {
		if(![luaExpression isEqualToString:@""]) value = [ds.ep parseExpression:luaExpression withValue:avalue];
		deviceRange = fabs(min - max);
		rawX = avalue;
		if(avalue > max) avalue = max;
		if(avalue < min) avalue = min;
		float percentOfDeviceRange = fabs(avalue - min) / deviceRange;
		value = expectedMin + (percentOfDeviceRange * expectedRange);
		preExpressionValue = value;
		if([expression length] != 0) {
			value = [ds.ep parseExpressionWithMapping:self];
		}
		if(value == DNR_NUMBER) return;
		if(polling) [ds.console print:[NSString stringWithFormat:@"Mapping %@ :: value %f :: destination %@", self.name, self.value, self.destination]];
		
		//[output addObject:FLOAT(value)];
		[self storeOutput:FLOAT(value)];

		[app sendValue:value forMapping:self];
	}
}

- (void)sendValues:(NSArray *)values toApp:(Application *)app {
	NSMutableString *msg = [NSMutableString string];
	NSMutableArray *processedValues = [NSMutableArray array];
	
	if(polling) { 
		[msg appendString:name];
		[msg appendString:@" :: "];
	}
	
	for(NSNumber *n in values) {
		float avalue = [n floatValue];
		if(![luaExpression isEqualToString:@""]) value = [ds.ep parseExpression:luaExpression withValue:avalue];

		rawX = avalue;
		if(avalue > max) avalue = max;
		if(avalue < min) avalue = min;
		
		float percentOfDeviceRange = fabs(avalue - min) / deviceRange;
		float v = expectedMin + (percentOfDeviceRange * expectedRange);
		
		if(![expression isEqualToString:@""]) v = [ds.ep parseExpressionWithMapping:self];
		
		if(value == DNR_NUMBER) continue;

		[processedValues addObject:FLOAT(v)];
		if(polling) {
			[msg appendString:[FLOAT(v) stringValue]];
			[msg appendString:@", "];
		}

		[output addObject:FLOAT(v)];
	}
	if(polling) [ds.console print:msg];

	[ds.osc sendValues:processedValues forMapping:self toApp:app];
}

- (NSString *) description {
	NSString *desc = [NSString stringWithFormat:@"%@ :: %d :: %d :: %f :: %f :: %@", name, deviceID, controlID, expectedMin, expectedMax, destination];
	return desc;
}

- (void)dealloc {
	[destination release];
	[controlName release];
	[output release];
	[dictionary release];
	[deviceName release];
	[name release];
	[expression release];
	[luaExpression release];
	[super dealloc];
}

@end
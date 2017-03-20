//
//  Control.m
//  DeviceServer_1
//
//  Created by charlie on 11/6/08.
//  Copyright 2008 One More Muse. All rights reserved.

#import "Control.h"
#import "Device.h"
#import "OSCManager.h"

@implementation Control
@synthesize name, usagePage, usage, device, deviceName, destination, expression, luaExpression, cID, polling, deviceID, min, max,
controlID, expectedMin, expectedMax, scalar, isConnected, dictionary, output, value;

- (id) initWithProperties:(NSDictionary *)props {
	if (self = [super init]) {
		output = [[NSMutableArray alloc] init];
		destination = [props objectForKey:@"destination"];
		[destination retain];
		expectedMin = [[props objectForKey:@"min"] floatValue];
		expectedMax = [[props objectForKey:@"max"] floatValue];
		
		[self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
		[self addObserver:self forKeyPath:@"deviceName" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkConnectionForNewDevice:) name:@"New Device" object:nil];		
	}
	
	return self;
}

- (void) checkConnectionForNewDevice:(id)notification {
	if(!isConnected) {
		if(((Device *)[notification object]).deviceID == deviceID) isConnected = YES;
		[ds.controlsTable reloadData];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	BOOL changeControl = NO;
	DeviceServer *ds = [NSApp delegate];

    if ([keyPath isEqual:@"name"]) {
		controlID = [device controlIDForName:name];
		changeControl = YES;
	}else if([keyPath isEqual:@"deviceName"]) {
		[deviceName release];
		deviceName = [NSMutableString stringWithString:[change objectForKey:@"new"]];
		[deviceName retain];
		
		//[self willChangeValueForKey:@"device"];
		device = [ds.dm deviceForName:deviceName];
		deviceID = device.deviceID;
		isConnected = YES;
		//[self didChangeValueForKey:@"device"];
		
		[self willChangeValueForKey:@"name"];
		[name release];
		name = [device.controlNames objectAtIndex:0];
		[name retain];
		[self didChangeValueForKey:@"name"];
		controlID = [device controlIDForName:name];

		changeControl = YES;
	}
	
	if(changeControl) {
		NSMutableDictionary *dict = [ds.luaManager controlPropertiesForControlWithID:controlID onDeviceWithID:deviceID];
		usage = [[dict objectForKey:@"usage"] intValue];
		usagePage = [[dict objectForKey:@"usagePage"] intValue];
		
		min = [[dict objectForKey:@"minimum"] floatValue];
		max = [[dict objectForKey:@"maximum"] floatValue];
		
		float range;
		if(min >= 0) {
			offset = 0;
			range = max - min;
		} else {
			range = (max - min);
			offset = 0 - min;
		}
		float expectedRange = expectedMax - expectedMin;
		scalar = expectedRange / range;
		return;
	}

    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];

}

- (void)setDevice:(int)newDeviceID control:(int)newControlID expression:(NSMutableString *)newExpression cID:(int)newcID {
	DeviceServer *ds = [NSApp delegate];

	if(deviceID != newDeviceID) {
		[self willChangeValueForKey:@"deviceName"];
		deviceID = newDeviceID;
		//[deviceName release];
		deviceName = [NSMutableString stringWithString:[ds.xml deviceNameForID:deviceID]];
		//[deviceName retain];		
		[self didChangeValueForKey:@"deviceName"];
		
		[self willChangeValueForKey:@"device"];
		device = [ds.dm deviceForName:deviceName];
		[self didChangeValueForKey:@"device"];
	}
		
	[self willChangeValueForKey:@"name"];
	//[name release];
	name = [device.controlNames objectAtIndex:newControlID];
	//[name retain];
	[self didChangeValueForKey:@"name"];
	
	if(![expression isEqualToString:newExpression]) {
		[self willChangeValueForKey:@"expression"];
		//[expression release];
		expression = [NSMutableString stringWithString:newExpression];
		//[expression retain];
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
	Control *control = (Control *)anObject;

	result = ([name isEqualToString:control.name] && [device isEqual: control.device]);
	
	return result;
}

- (void)sendValue:(float)avalue toApp:(Application *)app {
	DeviceServer *ds = [NSApp delegate];
	if(avalue > max) avalue = max;
	if(avalue < min) avalue = min;
	
	value = expectedMin + (avalue * scalar) + offset;
	
	if(![luaExpression isEqualToString:@""]) 
		value = [ds.ep parseExpressionWithControl:self];
	
	if(![expression isEqualToString:@""]) 
		//startValue = [ds.ep parseExpression:expression withValue:startValue];
		value = [ds.ep parseExpressionWithControl:self];
	
	if(polling) [ds.console print:[NSString stringWithFormat:@"Control %@ :: value %f", name, value]];
	[output addObject:FLOAT(value)];
	[ds.osc sendValue:value forControl:self toApp:app];
}

- (void)sendValues:(NSArray *)values toApp:(Application *)app {
	DeviceServer *ds = [NSApp delegate];
	NSMutableString *msg = [NSMutableString string];
	NSMutableArray *processedValues = [NSMutableArray array];
	
	if(polling) { 
		[msg appendString:name];
		[msg appendString:@" :: "];
	}
	
	for(NSNumber *n in values) {
		float value = [n floatValue];
		if(value > max) value = max;
		if(value < min) value = min;
		float v = expectedMin + (value * scalar) + offset;
		
		if(![luaExpression isEqualToString:@""]) v = [ds.ep parseExpression:luaExpression withValue:v];		
		if(![expression isEqualToString:@""]) v = [ds.ep parseExpression:expression withValue:v];
		
		[processedValues addObject:FLOAT(v)];
		if(polling) {
			[msg appendString:[FLOAT(v) stringValue]];
			[msg appendString:@", "];
		}
		[output addObject:FLOAT(v)];
	}
	if(polling) [ds.console print:msg];

	[ds.osc sendValues:processedValues forControl:self toApp:app];
}

- (NSString *) description {
	NSString *desc = [NSString stringWithFormat:@"%@ :: %d :: %d :: %f :: %f", destination, deviceID, controlID, expectedMin, expectedMax];
	return desc;
}

- (void)dealloc {
	[output release];
	[dictionary release];
	[deviceName release];
	[name release];
	[expression release];
	[luaExpression release];
	[super dealloc];
}

@end
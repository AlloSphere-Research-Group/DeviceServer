//
//  Functionality.m
//  DeviceServer3
//
//  Created by thecharlie on 11/14/10.
//  Copyright 2010 One More Muse. All rights reserved.
//

#import "Functionality.h"


@implementation Functionality

@synthesize min, max, name, destination;

- (NSString *) description {
	return [NSString stringWithFormat:@"name = %@, destination = %@, min= %f, max = %f", name, destination, min, max];
}

- (void) dealloc {
	[name release];
	[destination release];
	[super dealloc];
}

@end

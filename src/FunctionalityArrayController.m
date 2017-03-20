//
//  FuncationalityArrayController.m
//  DeviceServer3
//
//  Created by thecharlie on 11/12/10.
//  Copyright 2010 One More Muse. All rights reserved.
//

#import "FunctionalityArrayController.h"


@implementation FunctionalityArrayController

- (void)add:(id)sender {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"X Translation", @"name", @"/X", @"oscDestination", FLOAT(-1), @"min", FLOAT(1), @"max", nil];
	[self addObject:dict];
}
@end

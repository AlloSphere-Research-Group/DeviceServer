//
//  ConsoleDelegate.m
//  DeviceServer3
//
//  Created by charlie on 5/19/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import "ConsoleDelegate.h"
#define MAX_LINES 100

@implementation ConsoleDelegate

- (void)awakeFromNib {
	msgs = [NSMutableArray array];
	[msgs retain];
	[self retain];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [msgs count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
	return [msgs objectAtIndex:rowIndex];
}

- (void)print:(NSString *)msg {
	[msgs insertObject:msg atIndex:0];
	if([msgs count] > MAX_LINES) {
		[msgs removeObjectAtIndex:MAX_LINES];
	}
	[console reloadData];
}

- (void)dealloc {
	[msgs release];
	[super dealloc];
}
@end

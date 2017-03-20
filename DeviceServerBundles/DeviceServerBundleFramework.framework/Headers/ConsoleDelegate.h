//
//  ConsoleDelegate.h
//  DeviceServer3
//
//  Created by charlie on 5/19/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ConsoleDelegate : NSObject {
	NSMutableArray *msgs;
	IBOutlet NSTableView *console;
}

- (void)print:(NSString *)msg;

@end

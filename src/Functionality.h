//
//  Functionality.h
//  DeviceServer3
//
//  Created by thecharlie on 11/14/10.
//  Copyright 2010 One More Muse. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Functionality : NSObject {
	float min , max;
	NSString * name, *destination;
}

@property (assign, readwrite) float min, max;
@property (retain, readwrite) NSString *name, *destination;

@end

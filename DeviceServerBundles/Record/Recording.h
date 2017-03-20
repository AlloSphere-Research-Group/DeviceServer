//
//  Recording.h
//  Record
//
//  Created by charlie on 1/14/10.
//  Copyright 2010 One More Muse. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DeviceServer/DeviceServer.h>

@interface Recording : NSObject {
	DeviceServer *ds;
	NSMutableArray *events;
	NSString *name;
	NSDate *date;
}

@property (retain) NSMutableArray *events;
@property (retain) NSString *name;
@property (retain) NSDate *date;


- (id) initWithName:(NSString *)_name;
- (void) play:(id)object;
- (void) addEvent:(NSMutableDictionary *)event;

@end

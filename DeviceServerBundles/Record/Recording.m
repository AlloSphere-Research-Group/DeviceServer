//
//  Recording.m
//  Record
//
//  Created by charlie on 1/14/10.
//  Copyright 2010 One More Muse. All rights reserved.
//

#import "Recording.h"
#import <DeviceServer/ApplicationManager.h>
#import <DeviceServer/DeviceManager.h>


@implementation Recording
@synthesize events, date, name;

- (id) init {
	if(self = [super init]) {
		ds = [NSApp delegate];

		events = [[NSMutableArray alloc] init];
		date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
		
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		NSString *formattedDateString = [dateFormatter stringFromDate:date];

		name = [[NSMutableString alloc] initWithString:formattedDateString];
	}	
	return self;
}

- (id) initWithName:(NSString *)_name {
	Recording *r = [self init];
	r.name = _name;
	return r;
}

- (void) addEvent:(NSMutableDictionary *)event {
	[events addObject:event];
}

- (void) play:(id)object {
	//NSLog([events description]);
	/*double lastOffset = 0.0;
	for(NSMutableDictionary *e in events) {		
		double offset = [[e objectForKey:@"offset"] doubleValue];
		float value = [[e objectForKey:@"value"] floatValue];
		int deviceID = [[e objectForKey:@"deviceID"] intValue];
		int controlID = [[e objectForKey:@"controlID"] intValue];
		
		[NSThread sleepForTimeInterval:offset - lastOffset];
		lastOffset = offset;
		//NSString *eventDescription = [NSString stringWithFormat:@"time::%lf | value = %f, deviceID = %d, controlID = %d \n", offset, value, deviceID, controlID];
		//NSLog(eventDescription);
		[ds.am sendApplicationsValue:value fromControlWithID:controlID onDeviceWithID:deviceID];
	}*/
	[NSThread detachNewThreadSelector:@selector(playbackThread:) toTarget:self withObject:nil]; 
}

- (void) playbackThread:(id)anObject {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	double lastOffset = 0.0;
	for(NSMutableDictionary *e in events) {		
		double offset = [[e objectForKey:@"offset"] doubleValue];
		float value = [[e objectForKey:@"value"] floatValue];
		int deviceID = [[e objectForKey:@"deviceID"] intValue];
		int controlID = [[e objectForKey:@"controlID"] intValue];
		
		[NSThread sleepForTimeInterval:offset - lastOffset];
		lastOffset = offset;
		//NSString *eventDescription = [NSString stringWithFormat:@"time::%lf | value = %f, deviceID = %d, controlID = %d \n", offset, value, deviceID, controlID];
		//NSLog(eventDescription);
		[ds.am sendApplicationsValue:value fromControlWithID:controlID onDeviceWithID:deviceID];
		
		// TODO: Should use device name instead of device id in preparation for getting rid of master device list
	}
	
	[pool drain];
	
	[NSThread exit];
}

- (NSString *)description {
	NSMutableString *desc = [NSMutableString string];
	for(NSDictionary *d in events) {
		NSString *eventDescription = [NSString stringWithFormat:@"time::%lf | value = %f, deviceID = %d, controlID = %d \n",
										[[d objectForKey:@"offset"] doubleValue],
										[[d objectForKey:@"value"] floatValue],
										[[d objectForKey:@"deviceID"] intValue],
										[[d objectForKey:@"controlID"] intValue]
									  ];
		[desc appendString:eventDescription];
	}
	
	return desc;
}

- (void) dealloc {
	[events release];
	[name release];
	[date release];
	[super dealloc];
}
@end

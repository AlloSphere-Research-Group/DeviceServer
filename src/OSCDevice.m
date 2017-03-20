//
//  OSCDevice.m
//  DeviceServer3
//
//  Created by charlie on 5/26/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import "OSCDevice.h"
#import "ApplicationManager.h"

@implementation OSCDevice
@synthesize ipAddress, port;

- (void) processMessageWithValues:(lo_arg **)argv count:(int)count types:(const char *)types {
	NSString *controlName = [NSString stringWithCString:(char *)argv[1] encoding:1];
	int controlID = [self controlIDForName:controlName];
	if(count > 4) {
		NSMutableArray *values = [NSMutableArray array];
		for(int i = 2; i < count; i++) {
			//NSLog(@"val is %f", argv[i]->f);
			switch(types[i]) {
				case 'f':
					[values addObject:[NSNumber numberWithFloat:argv[i]->f]];
					break;
				case 'i':
					[values addObject:[NSNumber numberWithFloat:(float)argv[i]->i]];
					break;
				case 's':
					//lo_message_add_string(msg, [[values objectAtIndex:i] UTF8String]);
					break;
			}
		}
		
		//if(self.polling) [ds.console print:[NSString stringWithFormat:@"%@ :: %f", controlName,
			//[ds.console print:[NSString stringWithFormat:@"%@ :: %@", controlName, [[values description] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]];
		[ds.am sendApplicationsValues:values fromControlWithID:controlID onDevice:self];
		
	}else{
		if(self.polling) 
			[ds.console print:[NSString stringWithFormat:@"%@ :: %f", controlName, argv[2]->f ]];
		switch(types[2]) {
			case 'f':
				[ds.am sendApplicationsValue:argv[2]->f fromControlWithID:controlID onDevice:self];
				break;
			case 'i':
				[ds.am sendApplicationsValue:(float)argv[2]->i fromControlWithID:controlID onDevice:self];
				break;
		}
	}	
}

@end

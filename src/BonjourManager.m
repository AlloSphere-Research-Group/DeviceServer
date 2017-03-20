//
//  BonjourManager.m
//  DeviceServer3
//
//  Created by thecharlie on 5/3/10.
//  Copyright 2010 One More Muse. All rights reserved.
//

#import "BonjourManager.h"


@implementation BonjourManager

-(void)startService {
    netService = [[NSNetService alloc] initWithDomain:@"" type:@"_DeviceServer._tcp." 
												 name:@"" port:12000];
    netService.delegate = self;
    [netService publish];
}

-(void)stopService {
    [netService stop];
    [netService release]; 
    netService = nil;
}

-(void)dealloc {
    [self stopService];
    [super dealloc];
}

#pragma mark Net Service Delegate Methods
-(void)netService:(NSNetService *)aNetService didNotPublish:(NSDictionary *)dict {
    NSLog(@"Failed to publish: %@", dict);
}


@end

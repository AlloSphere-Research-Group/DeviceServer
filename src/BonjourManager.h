//
//  BonjourManager.h
//  DeviceServer3
//
//  Created by thecharlie on 5/3/10.
//  Copyright 2010 One More Muse. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BonjourManager : NSObject {
	NSNetService *netService;
}
-(void)startService;
-(void)stopService;
@end

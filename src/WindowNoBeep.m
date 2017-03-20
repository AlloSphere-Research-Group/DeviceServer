//
//  WindowNoBeep.m
//  DeviceServer3
//
//  Created by charlie on 8/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WindowNoBeep.h"


@implementation WindowNoBeep

-(void)noResponderFor:(SEL)keyDown { /* overriding this removes the System Beeps */ }

@end

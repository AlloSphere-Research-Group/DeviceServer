//
//  BundleLoader.h
//  BundleLoader
//
//  Created by charlie on 10/26/09.
//  Copyright 2009 One More Muse. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BundleLoader : NSObject {
	IBOutlet NSView *theView;
	IBOutlet NSTabView *tabs;
	NSMutableArray* topLevelObjs;
}

- (void) delayedInit;

@end
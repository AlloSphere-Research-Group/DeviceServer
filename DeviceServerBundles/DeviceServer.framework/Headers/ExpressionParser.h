//
//  ExpressionParser.h
//  columnSubClassTest
//
//  Created by charlie on 8/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
@class DeviceServer;
@class Mapping;

@interface ExpressionParser : NSObject {
	WebView *wv;
	DeviceServer *ds;
}

- (float) parseExpression:(NSString *)expression withValue:(float)x;
- (float) parseExpressionWithMapping:(Mapping *)m;

@end

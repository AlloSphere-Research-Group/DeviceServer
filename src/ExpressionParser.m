//
//  ExpressionParser.m
//  columnSubClassTest
//
//  Created by charlie on 8/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ExpressionParser.h"
#import "DeviceServer.h"
#import "Mapping.h"
//#import <LuaCore/LuaObjCBridge.h>
#import <LuaCocoa/LuaCocoa.h>
#import "Application.h"

@implementation ExpressionParser

- (id)init {
	if(self = [super init]) {
		ds = [NSApp delegate];
	}
	return self;
}

- (float)parseExpression:(NSString *)expression withValue:(float)x {	
	float result;
	NSNumber *num = FLOAT(x); // this seems retarded? converting to primitive and then back again?
	
	/*[ds.luaManager.lua pushGlobalObject:num withName:@"num"];
		
	[ds.luaManager.lua runBuffer:@"x = num:floatValue()"];
		
	[ds.luaManager.lua runBuffer:expression];
	
	[ds.luaManager.lua float:&result named:@"x"];*/
	
	return result;
}

- (float) parseExpressionWithMapping:(Mapping *)m {
	LuaCocoa *lua = m.application.lua;
	lua_State * L = lua.luaState;
	
	lua_rawgeti(L, LUA_REGISTRYINDEX, m.expressionID);
	//NSLog(@"expression id = %d, value = %f, raw = %f", m.expressionID, m.value, m.rawX);
	lua_pushnumber(L, m.value);
	lua_pushnumber(L, m.rawX);
	//lua_objc_pushid(L, m);
	LuaCocoa_PushInstance(L, m);
	if(lua_pcall(L, 3, 1, 0)) {
		printf("LUA ERROR ::: %s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
	double result = lua_tonumber(L, -1);
	
//	for (int i = lua_gettop(L); i > 0; i--) {
//		printf("%d: %s\n", i, lua_typename(L, lua_type(L, i)));
//	}
	
	lua_pop(L, 1);

	return (float)result;
}


- (void)dealloc {
	[super dealloc];
}

@end

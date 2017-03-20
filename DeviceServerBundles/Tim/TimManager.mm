#import "TimManager.h"
#include "al_PhasespaceManager.hpp"

// IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE

@implementation TimManager


- (id) init {
	if(self = [super init]) {}
	return self;
}

- (void) awakeFromNib {
	//[TimField1 setStringValue:@"Test String 1"];
	//[TimField2 setStringValue:@"Tim"];
	pollCount = 0;
	ds = [NSApp delegate];	
}

- (void) createDeviceWithName:(NSString *)name {
	[ds.dm createDeviceWithName:name];
}

- (void) sendValue:(float)value fromControlWithID:(int)controlID {
	Device *device = [ds.dm deviceForName:@"Tim"];
	
	//if(device.polling)
	//	[ds.console print:[NSString stringWithFormat:@"%@ :: controlID %d :: value %f", device.name, controlID, value]];
	
	[ds.am sendApplicationsValue:value fromControlWithID:controlID onDevice:device];
}

- (void) sendVec:(Vec3f)vec fromControlWithID:(int)controlID {
	Device *device = [ds.dm deviceForName:@"Tim"];
	
//	if(device.polling && controlID == 26) {
//		[ds.console print:[NSString stringWithFormat:@"%@ :: controlID %d :: value %f", device.name, controlID, vec.x]];
//		pollCount = 0;
//	}
	
	[ds.am sendApplicationsValue:vec.x fromControlWithID:controlID onDevice:device];
	[ds.am sendApplicationsValue:vec.y fromControlWithID:controlID+1 onDevice:device];
	[ds.am sendApplicationsValue:vec.z fromControlWithID:controlID+2 onDevice:device];
}


- (IBAction) TimConnect:(id)sender {
	[ds.console print:@"Connecting to PhaseSpace.."];
	[self createDeviceWithName:@"Tim"];
	
	tracker = PhasespaceManager::master();
	tracker->startThread();
	
	[ds.console print:@"Success"];
	
	lglove = new Glove(tracker->markers, 8);
	rglove = new Glove(tracker->markers, 0);
	
	[NSThread detachNewThreadSelector:@selector(stepThread) toTarget:self withObject:nil];
}

- (IBAction) TimDisconnect:(id)sender {
	tracker->stopThread();
	[ds.console print:@"Disconnected"];
	[ds.dm removeDevice:@"Tim"];
}
- (IBAction) TimStartBcast:(id)sender {
	//lo_address_free(dest);
	//[ds.console print:[NSString stringWithFormat:@"port: %@", [port stringValue] ]];
	//dest  = lo_address_new("255.255.255.255", [port.stringValue UTF8String]);
	[ds.console print:@"Broadcasting marker data on port 8008"];
	bcastMarkers=true;
}
- (IBAction) TimStopBcast:(id)sender {
	bcastMarkers=false;
}
- (IBAction) TimStartGlove:(id)sender {
	[ds.console print:@"Broadcasting glove data on port 8008"];
	bcastGloves=true;
}
- (IBAction) TimStopGlove:(id)sender {
	bcastGloves=false;
}
- (IBAction) TimStartRigid:(id)sender {
	[ds.console print:@"Broadcasting rigid data on port 8008"];
	bcastRigids=true;
}
- (IBAction) TimStopRigid:(id)sender {
	bcastRigids=false;
}

- (IBAction) TimAddRigid:(id)sender {
	int ret=0;
	int tries = 5;
	while(ret==0){
		ret = tracker->addRigidBodyFromVisibleMarkers();
		if(ret > 0 || tries-- == 0) break;
		sleep(1);
	}
	if( ret > 0 ) [ds.console print:@"rigid detected!"];
}

- (NSString *) name { return @"Tim"; }
- (BOOL) shouldDisplayInterface { return YES; }
- (NSView *) view { return view; }

- (void) stepThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	Pose rigids[10];
	int rigidSeen[10];
	Vec3f leds[30];
	int ledsSeen[30];
	int i;
	
	dest  = lo_address_new("255.255.255.255", "8008");
	
	while(1) {
		
		
		usleep(50000);
		
		
		tracker->getMarkers(leds, ledsSeen, 0, 30);
		for( i=0; i < 30; i++ ){
			if( ledsSeen[i] == 0 ){
				Vec3f p = leds[i];
				if (bcastMarkers) lo_send(dest, "/marker", "ifff", i, p.x, p.y, p.z);
				if(i < 3) [self sendVec:p fromControlWithID:(26+3*i)];
			}
		}	
		

		tracker->getRigids(rigids, rigidSeen, 0, 10);
		for( i=0; i < 10; i++ ){
			if( rigidSeen[i] == 0 ){
				Vec3f p = rigids[i].pos();
				Quatf q = rigids[i].quat();
				if(bcastRigids) lo_send(dest, "/rigid", "ifffffff", i, p.x, p.y, p.z, q.w, q.x, q.y, q.z );
				if( i == 0){
					[self sendVec:p fromControlWithID:35];
					[self sendValue:q.w fromControlWithID:38];
					[self sendValue:q.x fromControlWithID:39];
					[self sendValue:q.y fromControlWithID:40];
					[self sendValue:q.z fromControlWithID:41];
				}
			}
		}
		
		lglove->step(0.01f);
		rglove->step(0.01f);
		
		Vec3f lp = lglove->getCentroid();
		[self sendVec:lp fromControlWithID:0];
		if(bcastGloves) lo_send(dest,"/leftglove/position", "fff",lp.x,lp.y,lp.z);
		
		Vec3f rp = rglove->getCentroid();
		[self sendVec:rp fromControlWithID:3];
		if(bcastGloves) lo_send(dest,"/rightglove/position", "fff",rp.x,rp.y,rp.z);
		
		int i=0;
		for(i=0; i<4; i++){
			
			if( lglove->pinched[i] ){
				//first detection
				if( !lglove->wasPinched[i]){
					Vec3f v = lglove->pos[i];
					if(bcastGloves) lo_send(dest,"/leftglove/pinchOn", "ifff",i,v.x,v.y,v.z);
					[self sendValue:1 fromControlWithID:(18+i)];
				}else{
					Vec3f v = lglove->getPinchTranslate(i);
					if(bcastGloves) lo_send(dest,"/leftglove/pinchMove","ifff",i,v.x,v.y,v.z);
					if( i > 1) [self sendVec:v fromControlWithID:(3*i)];
				}
			}else if( lglove->wasPinched[i] ){
				if(bcastGloves) lo_send(dest,"/leftglove/pinchOff", "i",i);
				[self sendValue:0 fromControlWithID:(18+i)];
			}
		}
		for(i=0; i<4; i++){
			
			if( rglove->pinched[i] ){
				//first detection
				if( !rglove->wasPinched[i]){
					Vec3f v = rglove->pos[i];
					if(bcastGloves) lo_send(dest,"/rightglove/pinchOn", "ifff",i,v.x,v.y,v.z);
					[self sendValue:1 fromControlWithID:(22+i)];
				}else{
					Vec3f v = rglove->getPinchTranslate(i);
					if(bcastGloves) lo_send(dest,"/rightglove/pinchMove","ifff",i,v.x,v.y,v.z);
					if( i > 1) [self sendVec:v fromControlWithID:(6+3*i)];
				}
			}else if( rglove->wasPinched[i] ){
				if(bcastGloves) lo_send(dest,"/rightglove/pinchOff", "i",i);
				[self sendValue:0 fromControlWithID:(22+i)];
			}
		}
			
		
		
		
//		[self sendValue:c.x fromControlWithID:0];
//		[self sendValue:c.y fromControlWithID:1];
//		[self sendValue:c.z fromControlWithID:2];
//		
//		[self sendValue:(pitch /* *	k180byPI*/)	fromControlWithID:3];
//		[self sendValue:(roll /*  *	k180byPI */)	fromControlWithID:4];
//		[self sendValue:(yaw  /*  * k180byPI */)	fromControlWithID:5];
//		
//		[self sendValue:qw fromControlWithID:6];
//		[self sendValue:qx fromControlWithID:7];
//		[self sendValue:qy fromControlWithID:8];
//		[self sendValue:qz fromControlWithID:9];				
		
		//[ds.console print:[NSString stringWithFormat:@"yaw = %f, pitch = %f, roll = %f\n", yaw, pitch, roll]];
		//printf("yaw = %f, pitch = %f, roll = %f\n", yaw, pitch, roll);
		//}
			
		
    }
	lo_address_free(dest);			

	[pool drain];
}


@end

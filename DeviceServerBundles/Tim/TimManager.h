//
//  TimManager.h
//  Tim
//
//  IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE
 
/* MUST BE INCLUDED IN ALL TEMPLATES */
#import <Cocoa/Cocoa.h>
#import <DeviceServer/DeviceServer.h>
#import <DeviceServer/Device.h>
#import <DeviceServer/DeviceManager.h>
#import <DeviceServer/ApplicationManager.h>
#import <DeviceServer/OSCManager.h>
/* END MUST INCLUDES */

#include "allocore/math/al_Vec.hpp"
#include "al_PhasespaceManager.hpp"
#include "al_PhasespaceGlove.hpp"

using namespace al;

@interface TimManager : NSObject {
	IBOutlet NSTextField *port;
	//IBOutlet NSTextField *TimField2;
	IBOutlet NSView *view;
	DeviceServer *ds;
	
	PhasespaceManager *tracker;
	Glove *lglove;
	Glove *rglove;
	
	int pollCount;
	
}

bool bcastMarkers, bcastRigids, bcastGloves;
lo_address dest;

- (NSString *) name;
- (NSView *) view;
- (BOOL) shouldDisplayInterface;
- (IBAction) TimConnect:(id)sender;
- (IBAction) TimDisconnect:(id)sender;
- (IBAction) TimStartGlove:(id)sender;
- (IBAction) TimStopGlove:(id)sender;
- (IBAction) TimStartRigid:(id)sender;
- (IBAction) TimStopRigid:(id)sender;
- (IBAction) TimStartBcast:(id)sender;
- (IBAction) TimStopBcast:(id)sender;
- (IBAction) TimAddRigid:(id)sender;

/* Below method should be removed or modified */
//- (void) exampleCallback:(NSTimer *)timer;
- (void) sendValue:(float)value fromControlWithID:(int)controlID;
- (void) sendVec:(Vec3f)vec fromControlWithID:(int)controlID;

@end

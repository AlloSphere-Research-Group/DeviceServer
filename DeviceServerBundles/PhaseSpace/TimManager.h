//
//  PhasespaceManager.h
//  Phasespace
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

@interface PhaseSpaceManager : NSObject {
	IBOutlet NSTextField *port;
	//IBOutlet NSTextField *PhasespaceField2;
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
- (IBAction) PhasespaceConnect:(id)sender;
- (IBAction) PhasespaceDisconnect:(id)sender;
- (IBAction) PhasespaceStartGlove:(id)sender;
- (IBAction) PhasespaceStopGlove:(id)sender;
- (IBAction) PhasespaceStartRigid:(id)sender;
- (IBAction) PhasespaceStopRigid:(id)sender;
- (IBAction) PhasespaceStartBcast:(id)sender;
- (IBAction) PhasespaceStopBcast:(id)sender;
- (IBAction) PhasespaceAddRigid:(id)sender;

/* Below method should be removed or modified */
//- (void) exampleCallback:(NSTimer *)timer;
- (void) sendValue:(float)value fromControlWithID:(int)controlID;
- (void) sendVec:(Vec3f)vec fromControlWithID:(int)controlID;

@end

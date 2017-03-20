#import "PhaseSpaceManager.h"

#define ALLOSPHERE_IP "192.168.0.127"

float k180byPI = 180.0 / M_PI;
int _count = 0;
float RIGID_BODY[MARKER_COUNT][3] = {
  /*{ 0, 0,  0},
  { -12, 5,  88},
  { 60, 0,  66},*/
	{0,0,0},
	{ 138.9 - 154.2, 432.9 - 449, 561.4 - 508},
	{ 184.5 - 154.2, 433.2 - 449, 555.6 - 508},
};


void copy_p(const float *a, float *b) { for(int i = 0; i < 7; i++) b[i] = a[i]; }
void print_p(const float *p) { for(int i = 0; i < 7; i++) printf("%f ", p[i]); }

void owl_print_error(const char *s, int n) {
  if(n < 0) printf("%s: %d\n", s, n);
  else if(n == OWL_NO_ERROR) printf("%s: No Error\n", s);
  else if(n == OWL_INVALID_VALUE) printf("%s: Invalid Value\n", s);
  else if(n == OWL_INVALID_ENUM) printf("%s: Invalid Enum\n", s);
  else if(n == OWL_INVALID_OPERATION) printf("%s: Invalid Operation\n", s);
  else printf("%s: 0x%x\n", s, n);
}

@implementation PhaseSpaceManager

- (id) init {
	if(self = [super init]) {
		pollCount = 0;
		_pollCount = 0;
	}
	return self;
}

- (void) receiveThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while(1) {
		int err;
		// get the rigid body
		int n = owlGetRigids(&rigid, 1);
		// get markers
		int m = owlGetMarkers(markers, 3);

		// check for error
		if((err = owlGetError()) != OWL_NO_ERROR) {
			owl_print_error("error", err);
			break;
		}
		// no data yet

		if(n == 0) continue;

		if(n > 0) {
			if(rigid.cond > 0) {
				float inv_pose[7];
				copy_p(rigid.pose, inv_pose);
				invert_p(inv_pose);
				//if(_count++ %30 == 0) {
					//printf("\nRigid: ");
				  
					//#define POSE(x, y, z, angle, vx, vy, vz) \
					// pose is x, y, z position in mm  w, x, y, z quaternion
				  
					// TODO: TRANSLATE QUATERNION INTO EULER ANGLES, SEND OSC TO DEVICE SERVER
					float qw = rigid.pose[3];
					float qx = rigid.pose[4];
					float qy = rigid.pose[5];
					float qz = rigid.pose[6];
					
					float yaw   = atan2f(2*qy*qw-2*qx*qz , 1 - 2*(qy * qy) - 2*(qz * qz));
					float pitch = asinf(2*qx*qy + 2*qz*qw); 
					float roll  = atan2f(2*qx*qw-2*qy*qz , 1 - 2*(qx * qx) - 2*(qz * qz));
					
					[self sendValue:rigid.pose[0] fromControlWithID:0];
					[self sendValue:rigid.pose[1] fromControlWithID:1];
					[self sendValue:rigid.pose[2] fromControlWithID:2];
					
					[self sendValue:(pitch /* *	k180byPI*/)	fromControlWithID:3];
					[self sendValue:(roll /*  *	k180byPI */)	fromControlWithID:4];
					[self sendValue:(yaw  /*  * k180byPI */)	fromControlWithID:5];
				
					[self sendValue:qw fromControlWithID:6];
					[self sendValue:qx fromControlWithID:7];
					[self sendValue:qy fromControlWithID:8];
					[self sendValue:qz fromControlWithID:9];				
							
					//[ds.console print:[NSString stringWithFormat:@"yaw = %f, pitch = %f, roll = %f\n", yaw, pitch, roll]];
					//printf("yaw = %f, pitch = %f, roll = %f\n", yaw, pitch, roll);
				//}
			}
		}
    }
	[pool drain];

	owlDone();
}

- (void) awakeFromNib {
	ds = [NSApp delegate];
}


- (void) createDeviceWithName:(NSString *)name {
	[ds.dm createDeviceWithName:name];
}

- (void) sendValue:(float)value fromControlWithID:(int)controlID {
	Device *device = [ds.dm deviceForName:@"PhaseSpace"];
	
	if(device.polling && _pollCount++ % 10 == 0) {
		pollCount++;
		_pollCount = 0;
	}
	
	if(device.polling && pollCount % 30 == 0)
		[ds.console print:[NSString stringWithFormat:@"%@ :: control %@ :: value %f", device.name, [device.controlNames objectAtIndex:controlID], value]];
	
	[ds.am sendApplicationsValue:value fromControlWithID:controlID onDevice:device];
}

- (IBAction) PhaseSpaceConnect:(id)sender {
	[ds.console print:@"PhaseSpace loaded"];
	[self createDeviceWithName:@"PhaseSpace"];
	
	int ret = owl_scan(ALLOSPHERE_IP, 8999, "DeviceServer logging in...", 10, &cons, 1);
	if(ret < 0) {
		NSLog(@"ERROR FINDING SERVER");
		return;
	}else{
		NSLog(@"found a server!!!");
		int err = owlInit(ALLOSPHERE_IP, 0);
	}
	
	int tracker = 0;  
	owlTrackeri(tracker, OWL_CREATE, OWL_RIGID_TRACKER);

	for(int i = 0; i < MARKER_COUNT; i++) {
		owlMarkeri(MARKER(tracker, i), OWL_SET_LED, i);
		owlMarkerfv(MARKER(tracker, i), OWL_SET_POSITION, RIGID_BODY[i]);
	}

	// activate tracker
	owlTracker(tracker, OWL_ENABLE);
	owlSetFloat(OWL_FREQUENCY, 30);
  
	// start streaming
	owlSetInteger(OWL_STREAMING, OWL_ENABLE);
	
	[NSThread detachNewThreadSelector:@selector(receiveThread) toTarget:self withObject:nil];
}

- (IBAction) PhaseSpaceDisconnect:(id)sender {
	owlDone();
	[ds.dm removeDevice:@"PhaseSpace"];
}

- (NSString *) name { return @"PhaseSpace"; }
- (BOOL) shouldDisplayInterface { return YES; }
- (NSView *) view { return view; }

@end

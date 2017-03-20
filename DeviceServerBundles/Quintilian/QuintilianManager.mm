#import "QuintilianManager.h"

OWLMarker markers[MARKER_COUNT];

/* Hands */

// Left Hand
hand *LH = new hand(new fingerTip(0,0,0), new fingerTip(0,0,0));        // introducing... your Left Hand
hand *prevLH = new hand(new fingerTip(0,0,0), new fingerTip(0,0,0));    // previous position of the Left Hand
hand *usableLH = new hand(new fingerTip(0,0,0), new fingerTip(0,0,0));  // Only use the hand info when both fingers of interest are detected

// Right Hand
hand *RH = new hand(new fingerTip(0,0,0), new fingerTip(0,0,0));        // introducing... your Right Hand
hand *prevRH = new hand(new fingerTip(0,0,0), new fingerTip(0,0,0));    // previous position of the Right Hand
hand *usableRH = new hand(new fingerTip(0,0,0), new fingerTip(0,0,0));  // Only use the hand info when both fingers of interest are detected
hand *t0RH = new hand(new fingerTip(0,0,0), new fingerTip(0,0,0));  // Only use the hand info when both fingers of interest are detected

bool trackingLH = false;
bool trackingRH = false;
char tempString[16];

/* Gesture Variables */

float leftPinchThreshold = 0.0035f;
float rightPinchThreshold = 0.0030f;

int leftForeFingerMarkerID = 0;     // ID corresponds to ID in the PhaseSpace Tracking System
int leftThumbMarkerID = 1;     
int rightForeFingerMarkerID = 2;
int rightThumbMarkerID = 3;
int numberOfMarkersOnEachHand = 2;
int numberOfLeftMarkersDetected = 0;
int numberOfRightMarkersDetected = 0;

float resetThreshold = 0.0009f;

sVector3D *leftHandCentroid = new sVector3D();  //  Center point for left hand
sVector3D *tempLHC = new sVector3D();

sVector3D *rightHandCentroid = new sVector3D(); //  Center point for right hand
sVector3D *tempRHC = new sVector3D();

sVector3D *u0 = new sVector3D();   //  Vector to hold initial line joining two hand pinches
sVector3D *ut = new sVector3D();   //  Vector to hold current line coordinates

// Rotation

float xAngle = 0.0f;       //  Angle of the line's rotation (rad)
float prevXAngle = 0.0f;   //  Previous value of uAngle to find the difference and rotate accordingly
float rX = 0.0f;

float yAngle = 0.0f;
float prevYAngle = 0.0f;
float rY = 0.0f;

float zAngle = 0.0f;
float prevZAngle = 0.0f;
float rZ = 0.0f;

bool  uFlag = false;    //  Flag to decide initial uVector line
bool  rXFlag = false;   //  True if rotating around the X axis
bool  rYFlag = false;
bool  rZFlag = false;

// Translation

float tX = 0.0f;    //  Stores X Difference values
float tY = 0.0f;
float tZ = 0.0f;

bool tXFlag = false;    // True if translating in X
bool tYFlag = false;
bool tZFlag = false;

bool tPinch = false;

// Scaling

float sX = 0.0f;
float sY = 0.0f;
float sZ = 0.0f;

/* Space Parametes used to map to GL coordinates */

float xMin = -3000.0f;  float xMax = 3000.0f;   // 1000 to 2200
float yMin = -500.0f;   float yMax = 800.0f;    // 0 to 600
float zMin = -600.0f;   float zMax = 600.0f;    // 600 to 1200

/* Function Declarations */
void owl_print_error(const char *s, int n);
float map (float value, float srcMin, float srcMax, float destMin, float destMax);
void handleMarkers(int n);
void detectGestures();
// IMPORTANT: REMEMBER TO CHANGE YOUR MASTER DEVICE LIST AFTER BUILDING THIS BUNDLE

@implementation QuintilianManager

- (id) init {
	NSLog(@"HELLO");
	if(self = [super init]) {}
	return self;
}

- (void) receivePSDataThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// main loop
	while(1) {
		int err;
		
		// get some markers
		int n = owlGetMarkers(markers, MARKER_COUNT);
		
		// check for error
		if((err = owlGetError()) != OWL_NO_ERROR) {
			owl_print_error("error", err);
			break;
		}
		
		// no data yet
		if(n == 0)
			continue;
		
		if(n > 0) {
			/*
			for(int i = 0; i < n; i++)
				if(markers[i].cond > 0) {
					if(i == 0){
						[self sendValue:markers[i].x fromControlWithID:0];
						[self sendValue:markers[i].y fromControlWithID:1];
						[self sendValue:markers[i].z fromControlWithID:2];
					}
				}
			 */
			
			// handle markers here
            handleMarkers(n);
            
            if (usableRH->forefinger->y > 0.0f)	// detect if the Right Hand is elevated
			{
				float leftPinch = 0.0f;
				float rightPinch = 0.0f;
				
                detectGestures();    
				
				if(usableLH->pinched(leftPinchThreshold)) leftPinch = 1.0f;
				if(usableRH->pinched(rightPinchThreshold)) rightPinch = 1.0f;
				
				//send LH Location Data
				[self sendValue:usableLH->forefinger->x fromControlWithID:0];
				[self sendValue:usableLH->forefinger->y fromControlWithID:1];
				[self sendValue:usableLH->forefinger->z fromControlWithID:2];
				
				//send RH Location Data
				[self sendValue:usableRH->forefinger->x fromControlWithID:3];
				[self sendValue:usableRH->forefinger->y fromControlWithID:4];
				[self sendValue:usableRH->forefinger->z fromControlWithID:5];
				
				//send pinch Values
				[self sendValue:leftPinch fromControlWithID:6];
				[self sendValue:rightPinch fromControlWithID:7];
				
				//send Translation Data
				[self sendValue:tX fromControlWithID:8];
				[self sendValue:tY fromControlWithID:9];
				[self sendValue:tZ fromControlWithID:10];
				
				//send Rotation Data
				[self sendValue:rX fromControlWithID:11];
				[self sendValue:rY fromControlWithID:12];
				[self sendValue:rZ fromControlWithID:13];
				
				//send Scale Data
				[self sendValue:sX fromControlWithID:14];
				[self sendValue:sY fromControlWithID:15];
				[self sendValue:sZ fromControlWithID:16];
			}
		}
		
	}
	
	// cleanup
	owlDone();
	
	[pool drain];
}

- (void) awakeFromNib {
	[QuintilianField1 setStringValue:@"Test String 1"];
	[QuintilianField2 setStringValue:@"Quintilian"];
	ds = [NSApp delegate];
	
	// example message triggering... for example purposes only. Triggers a message to be sent every second
//	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(exampleCallback:) userInfo:nil repeats:YES];
}

- (void) createDeviceWithName:(NSString *)name {
	[ds.dm createDeviceWithName:name];
}

- (void) sendValue:(float)value fromControlWithID:(int)controlID {
	Device *device = [ds.dm deviceForName:@"Quintilian"];
	
	if(device.polling)
		[ds.console print:[NSString stringWithFormat:@"%@ :: controlID %d :: value %f", device.name, controlID, value]];
	
	[ds.am sendApplicationsValue:value fromControlWithID:controlID onDevice:device];
}

- (IBAction) QuintilianConnect:(id)sender {
	[ds.console print:@"Quintilian loaded"];
	[self createDeviceWithName:@"Quintilian"];
	
	int tracker;
	
	std::cout << "outside OWLinit now" << std::endl;
	
	int owlError = owlInit(SERVER_NAME, INIT_FLAGS);
	if ( owlError >= 0)
	{
		std::cout << "after OWLinit" << std::endl;
		
		// create tracker 0
		tracker = 0;
		owlTrackeri(tracker, OWL_CREATE, OWL_POINT_TRACKER);
		
		// set markers
		for(int i = 0; i < MARKER_COUNT; i++)
			owlMarkeri(MARKER(tracker, i), OWL_SET_LED, i);
		
		// activate tracker
		owlTracker(tracker, OWL_ENABLE);
		
		// flush requests and check for errors
		if(owlGetStatus()) {
			// set default frequency
			owlSetFloat(OWL_FREQUENCY, SET_OWL_FREQUENCY);
			
			// start streaming
			owlSetInteger(OWL_STREAMING, OWL_ENABLE);
			
			[NSThread detachNewThreadSelector:@selector(receivePSDataThread) toTarget:self withObject:nil];
		}
		
		else {
			owl_print_error("error in point tracker setup", owlGetError());
		}
		
	}else{
		NSLog(@"bad news...%d", owlError);
	}
	
}

- (NSString *) name { return @"Quintilian"; }
- (BOOL) shouldDisplayInterface { return YES; }
- (NSView *) view { return view; }

@end

void handleMarkers(int n)
{
    LH->foreFingerReceived = false;
    LH->thumbReceived = false;
    
    RH->foreFingerReceived = false;
    RH->thumbReceived = false;
    
    trackingLH = false;
    trackingRH = false;
    
    tempLHC->set(0.0f, 0.0f, 0.0f);
    tempRHC->set(0.0f, 0.0f, 0.0f);
    
    numberOfLeftMarkersDetected = 0;
    numberOfRightMarkersDetected = 0;
	
    for(int i = 0; i < n; i++)
    {
        if(markers[i].cond > 0) 
        {
            
            if (i == leftForeFingerMarkerID)    // check for forefinger
            {
                LH->forefinger->x = map(markers[i].x,xMin,xMax,1.0f,-1.0f);
                LH->forefinger->y = map(markers[i].y,yMin,yMax,-1.0f,1.0f);
                LH->forefinger->z = map(markers[i].z,zMin,zMax,-1.0f,1.0f);
                LH->foreFingerReceived = true;
            }
            
            else if (i == leftThumbMarkerID)    // check for forefinger
            {
                LH->thumb->x = map(markers[i].x,xMin,xMax,1.0f,-1.0f);
                LH->thumb->y = map(markers[i].y,yMin,yMax,-1.0f,1.0f);
                LH->thumb->z = map(markers[i].z,zMin,zMax,-1.0f,1.0f);
                LH->thumbReceived = true;
            }
            
            else if (i == rightForeFingerMarkerID)    // check for forefinger
            {
                RH->forefinger->x = map(markers[i].x,xMin,xMax,1.0f,-1.0f);
                RH->forefinger->y = map(markers[i].y,yMin,yMax,-1.0f,1.0f);
                RH->forefinger->z = map(markers[i].z,zMin,zMax,-1.0f,1.0f);
                RH->foreFingerReceived = true;
            }
            
            else if (i == rightThumbMarkerID)    // check for forefinger
            {
                RH->thumb->x = map(markers[i].x,xMin,xMax,1.0f,-1.0f);
                RH->thumb->y = map(markers[i].y,yMin,yMax,-1.0f,1.0f);
                RH->thumb->z = map(markers[i].z,zMin,zMax,-1.0f,1.0f);
                RH->thumbReceived = true;
            }
            
            if (LH->pinchPossible())            // only consider data when both fingers are detected
            {
                
                prevLH->operator=(*usableLH);
                usableLH->operator=(*LH);     
                
                trackingLH = true;
                LH->foreFingerReceived = false; // set these back to false so this doesn't change when any other fingers are processed
                LH->thumbReceived = false;
                
            }
            
            if (RH->pinchPossible()) 
            {
                
                prevRH->operator=(*usableRH);
                usableRH->operator=(*RH);     
                
                trackingRH = true;
                RH->foreFingerReceived = false;
                RH->thumbReceived = false;
            }
            
            // check for left or right hand markers to calculate centroids of the hands
            if((i >= (leftThumbMarkerID - numberOfMarkersOnEachHand)) && (i <= leftThumbMarkerID))    // then it's a LeftHand Marker
            {
                tempLHC->x += map(markers[i].x,xMin,xMax,1.0f,-1.0f);
                tempLHC->y += map(markers[i].y,yMin,yMax,-1.0f,1.0f);
                tempLHC->z += map(markers[i].z,zMin,zMax,-1.0f,1.0f);
                
                numberOfLeftMarkersDetected++;
            }
            
            if((i >= (rightThumbMarkerID - numberOfMarkersOnEachHand)) && (i <= rightThumbMarkerID))    // then it's an RightHand Marker
            {
                tempRHC->x += map(markers[i].x,xMin,xMax,1.0f,-1.0f);
                tempRHC->y += map(markers[i].y,yMin,yMax,-1.0f,1.0f);
                tempRHC->z += map(markers[i].z,zMin,zMax,-1.0f,1.0f);
                
                numberOfRightMarkersDetected++;
            }
        }
    }
    
    tempLHC->x /= numberOfLeftMarkersDetected;
    tempLHC->y /= numberOfLeftMarkersDetected;
    tempLHC->z /= numberOfLeftMarkersDetected;
    
    tempRHC->x /= numberOfRightMarkersDetected;
    tempRHC->y /= numberOfRightMarkersDetected;
    tempRHC->z /= numberOfRightMarkersDetected;
    
    leftHandCentroid = tempLHC;     // assign left hand centroid
    rightHandCentroid = tempRHC;    // assign right hand centroid
}

void detectGestures()
{
	//    cout << usableRH->pinchDistance() << endl;
    
    lo_message loLeftHand, loRightHand, loTranslate, loRotate, loScale;
    
    tX = 0.0f;
    tY = 0.0f;
    tZ = 0.0f;
    
    rX = 0.0f;
    rY = 0.0f;
    rZ = 0.0f;
    
	//    sX = 0.0f;
	//    sY = 0.0f;
	//    sZ = 0.0f;    
    
    tXFlag = false;
    tYFlag = false;
    tZFlag = false;
    
    /*
     // Reset when both hands collide
     if(leftHandCentroid->distanceSqrd(rightHandCentroid) < resetThreshold)
     {
     cout << "RESET RESET RESET !!! " << endl;
     my_cam.resetCam();
     }
	 */
	// Left Hand Pinch Zoom || Not implemented but could be for left handed people
	if(usableLH->pinched(leftPinchThreshold) && !usableRH->pinched(rightPinchThreshold))
	{
		//     my_cam._cameraDistZ += (usableLH->forefinger->z- prevLH->forefinger->z)*10.0f;
		if(uFlag) uFlag = false;
		prevXAngle = prevYAngle = prevZAngle = 0.0f;
		xAngle = yAngle = zAngle = 0.0f;
		rXFlag = false;
		rYFlag = false;
		rZFlag = false;
	}
	
    
    //--------------------------------- TRANSLATION ---------------------------------//
    
    // Right Hand Pinch Gestures
    if(usableRH->pinched(rightPinchThreshold) && !usableLH->pinched(leftPinchThreshold) && !tPinch)
    {
		NSLog(@"PINCHING");
        tX = 0.0f;   // 20
        tY = 0.0f;    // 2
        tZ = 0.0f;
		
		t0RH->operator=(* usableRH);
        
        rXFlag = false;
        rYFlag = false;
        rZFlag = false;
        
		//        cout << (usableRH->forefinger->x) << " " << (usableRH->forefinger->y) << " " << (usableRH->forefinger->z) << endl;
        
        // Find out Translation flags (establish the direction to translate, which is the dimension that changes the most)
        
        if (fabs(tX) > fabs(tY))
        {
            if (fabs(tX) > fabs(tZ))
            {
                tXFlag = true;
                tYFlag = false;
                tZFlag = false;
            }
            else
            {
                tXFlag = false;
                tYFlag = false;
                tZFlag = true;
            }
        }
        
        else
        {
            if (fabs(tY) > fabs(tZ))
            {
                tXFlag = false;
                tYFlag = true;
                tZFlag = false;
            }
            else
            {
                tXFlag = false;
                tYFlag = false;
                tZFlag = true;
            }
        }
        
        if(uFlag) uFlag = false;
        prevXAngle = prevYAngle = prevZAngle = 0.0f;
        xAngle = yAngle = zAngle = 0.0f;
		
		tPinch = true;
    }
	
	else if(usableRH->pinched(rightPinchThreshold) && !usableLH->pinched(leftPinchThreshold) && tPinch)
	{
		tX = (usableRH->forefinger->x - t0RH->forefinger->x)*60.0f;   // 20
        tY = (usableRH->forefinger->y - t0RH->forefinger->y)*3.0f;    // 2
        tZ = (usableRH->forefinger->z - t0RH->forefinger->z)*2.0f;		
		
        rXFlag = false;
        rYFlag = false;
        rZFlag = false;
	}
	
    //--------------------------------- END TRANSLATION ---------------------------------//
    
    //--------------------------------- ROTATION ---------------------------------//
    
    // Both Hands Pinch Gesture
    if (usableLH->pinched(leftPinchThreshold) && usableRH->pinched(rightPinchThreshold) && !uFlag) 
    {
        u0->x = usableRH->forefinger->x - usableLH->forefinger->x;
        u0->y = usableRH->forefinger->y - usableLH->forefinger->y;
        u0->z = usableRH->forefinger->z - usableLH->forefinger->z;
        
        u0->normalize();  // normalize ???
        
        xAngle = (atan2f(u0->z, u0->x))*180.0f/M_PI;
        yAngle = (atan2f(u0->x, u0->y))*180.0f/M_PI;
        zAngle = (atan2f(u0->y, u0->z))*180.0f/M_PI;
        
		//        cout << xAngle << "     " << yAngle << "     " <<  zAngle << endl;
        
		// Find the separation between two hands and lock the axis that has maximum separation
        
        float cX = (usableRH->forefinger->x - usableLH->forefinger->x)*3.0f;  // because X is 3 times the other two dimensions
        float cY = (usableRH->forefinger->y - usableLH->forefinger->y)*1.0f;
        float cZ = (usableRH->forefinger->z - usableLH->forefinger->z)*1.0f;
        
		//        cout << sX << "     " << sY << "     " <<  sZ << endl;
        
        if (fabs(cX) >= fabs(cY))
        {
            if (fabs(cX) >= fabs(cZ))
                rYFlag = true;
            else
                rXFlag = true;
        }
        else
        {
            if (fabs(cY) >= fabs(cZ))
                rZFlag = true;
            else
                rXFlag = true; 
        }		
        uFlag = true;
		tPinch = false;
    }
	
    if (usableLH->pinched(leftPinchThreshold) && usableRH->pinched(rightPinchThreshold) && uFlag )
    {
        
        ut->x = usableRH->forefinger->x - usableLH->forefinger->x;
        ut->y = usableRH->forefinger->y - usableLH->forefinger->y;
        ut->z = usableRH->forefinger->z - usableLH->forefinger->z;
        
        ut->normalize();  // normalize ???
        
        if (rXFlag) //  which means line is parallel to Z axis and rotating around the X axis according to rX
        {
            prevZAngle = zAngle;
            zAngle = (atan2f(ut->y, ut->z))*180.0f/M_PI;
            
            float tempRX = (prevZAngle - zAngle);
            rX = tempRX;
            
            sZ = ut->magnitudeSqrd() - u0->magnitudeSqrd();
        }
        
        else if (rYFlag) //  which means line is parallel to X axis and rotating around the Y axis according to rY
        {
            prevXAngle = xAngle;
            xAngle = (atan2f(ut->z, ut->x))*180.0f/M_PI;
            
            float tempRY = (prevXAngle - xAngle);
            rY = tempRY;
            
            sX = ut->magnitudeSqrd() - u0->magnitudeSqrd();
			
        }
        
        else if (rZFlag) //  which means line is parallel to Y axis and rotating around the Z axis according to rZ
        {
            prevYAngle = yAngle;
            yAngle = (atan2f(ut->x, ut->y))*180.0f/M_PI;
            
            float tempRZ = (prevYAngle - yAngle);
            rZ = tempRZ;
            
            sY = ut->magnitudeSqrd() - u0->magnitudeSqrd();
        }
        
		//        cout << xAngle << "      " << yAngle << "      " << zAngle << endl;
		
        tX = 0.0f;
        tY = 0.0f;
        tZ = 0.0f; 
		
		tPinch = false;
    }
    
    if (!usableLH->pinched(leftPinchThreshold) && !usableRH->pinched(rightPinchThreshold))
    {
        rXFlag = false;
        rYFlag = false;
        rZFlag = false;
        
        prevXAngle = 0.0f;
        prevYAngle = 0.0f;
        prevZAngle = 0.0f;
        
        xAngle = 0.0f;
        yAngle = 0.0f;
        zAngle = 0.0f;
		
		tPinch = false;
    }
    //if(tX != 0) NSLog(@"TX: %f", tX);
    //--------------------------------- END ROTATION ---------------------------------//
}

void owl_print_error(const char *s, int n) {
	if(n < 0) printf("%s: %d\n", s, n);
	else if(n == OWL_NO_ERROR) printf("%s: No Error\n", s);
	else if(n == OWL_INVALID_VALUE) printf("%s: Invalid Value\n", s);
	else if(n == OWL_INVALID_ENUM) printf("%s: Invalid Enum\n", s);
	else if(n == OWL_INVALID_OPERATION) printf("%s: Invalid Operation\n", s);
	else printf("%s: 0x%x\n", s, n);
}

float map (float value, float srcMin, float srcMax, float destMin, float destMax)
{
    float deltaSrc = srcMax - srcMin;
    float deltaDest = destMax - destMin;
    return (((value-srcMin)/deltaSrc*deltaDest) + destMin);
}

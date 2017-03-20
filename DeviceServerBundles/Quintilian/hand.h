//
//  hand.h
//  Quintilian
//
//  Created by Ritesh Lala on 11/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "fingerTip.h"
#include <stdio.h>

//#define pinchDetectThreshold 0.0035f

class hand{

public:
    fingerTip* forefinger;
    fingerTip* thumb;
    bool foreFingerReceived;
    bool thumbReceived;
    
public:
    hand& operator=(const hand& temp);
    
    hand()
    {
        forefinger = new fingerTip();
        thumb = new fingerTip();
        foreFingerReceived = true;
        thumbReceived = true;
    }
    
    hand(fingerTip* ff, fingerTip* th)
    {
        forefinger = ff;
        thumb = th;
        foreFingerReceived = true;
        thumbReceived = true;
    }
    
    hand(const hand& h) // copy constructor
    {
        
        forefinger = new fingerTip(*h.forefinger);
        thumb = new fingerTip(*h.thumb);
        foreFingerReceived = true;
        thumbReceived = true;
    }
    
    ~hand()
    {
        delete forefinger;
        delete thumb;
    }
    
    float pinchDistance()
    {
        return forefinger->distanceSqrd(thumb);
    }
    
    bool pinched(float pinchDetectThreshold)
    {
        return ( pinchDistance() < pinchDetectThreshold ? true : false );
    }
    
    bool pinchPossible()
    {
        if (foreFingerReceived && thumbReceived) return true;
        else return false;
    }
    
    

};

hand& hand::operator=(const hand& temp)
{
       
    if(this == &temp) { return *this;}
    
    else
    {
        delete forefinger;
        forefinger = new fingerTip(*temp.forefinger);
        
        delete thumb;
        thumb = new fingerTip(*temp.thumb);
        
        foreFingerReceived = temp.foreFingerReceived;
        thumbReceived = temp.thumbReceived;
        
        return *this;
    }
    
}
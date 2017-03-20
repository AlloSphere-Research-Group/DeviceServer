//
//  fingerTip.h
//  Quintilian
//
//  Created by Ritesh Lala on 11/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

class fingerTip{
    
public:
    float x;
    float y;
    float z;
    
public:
    fingerTip()
    {
        x = y = z = 0.0f;
    }
    
    fingerTip(float fx, float fy, float fz)
    {
        x = fx;
        y = fy;
        z = fz;
    }
    
    fingerTip(const fingerTip& fT)  // copy constructor
    {
        x = fT.x;
        y = fT.y;
        z = fT.z;
    }
    
    ~fingerTip()
    {
        x = y = z = 0.0f;
    }
    
    float distanceSqrd (fingerTip* b)
    {
        return (pow((b->x - x),2.0f) + pow((b->y - y),2.0f) + pow((b->z - z),2.0f));
    }
    
    fingerTip& operator=(const fingerTip & temp);

};

fingerTip& fingerTip::operator=(const fingerTip & temp)
{
    if (this == &temp) return *this;
    
    else 
    {
        x = temp.x;
        y = temp.y;
        z = temp.z;
        
        return *this;
    }
}
    
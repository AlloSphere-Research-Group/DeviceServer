//
//  sVector3D.h
//  Quintilian
//  3D Vector Class
//  Created by Ritesh Lala on 11/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <math.h>

class sVector3D{
    
public:
    float x;
    float y;
    float z;
    
public:
    sVector3D()
    {
        x = 0.0f;
        y = 0.0f;
        z = 0.0f;
    }
    
    sVector3D(float sX, float sY, float sZ)
    {
        x = sX;
        y = sY;
        z = sZ;
    }
    
    sVector3D(const sVector3D& sV3D)    // Copy Constructor
    {
        x = sV3D.x;
        y = sV3D.y;
        z = sV3D.z;
    }
    
    ~sVector3D()
    {
        x = y = z = 0.0f;
    }
    
    float magnitudeSqrd()
    {
        return (x*x + y*y + z*z);
    }
    
    void set(float sX, float sY, float sZ)
    {
        x = sX;
        y = sY;
        z = sZ;
    }
    
    void normalize()
    {
        x /= sqrtf(magnitudeSqrd());
        y /= sqrtf(magnitudeSqrd());
        z /= sqrtf(magnitudeSqrd());
    }
    
    float distanceSqrd (sVector3D* sV3D)
    {
        return (pow((sV3D->x - x),2.0f) + pow((sV3D->y - y),2.0f) + pow((sV3D->z - z),2.0f));
    }
    
    sVector3D& unitVector()
    {
        sVector3D* unit = new sVector3D();
        
        if (magnitudeSqrd())
        {        
            unit->x = x/sqrtf(magnitudeSqrd());
            unit->y = y/sqrtf(magnitudeSqrd());
            unit->z = z/sqrtf(magnitudeSqrd());
        }
                
        return *unit;
    }
    
    float sDot(sVector3D& sV3D)
    {
        return (x*sV3D.x + y*sV3D.y + z*sV3D.z);
    }
    
    sVector3D& sCross(sVector3D& sV3D)
    {
        float cX = y*sV3D.z - sV3D.y*z;
        float cY = - x*sV3D.z + sV3D.x*z;
        float cZ = x*sV3D.y - sV3D.x*y;
        
        sVector3D* cross = new sVector3D(cX, cY, cZ);
        return *cross;
    }
    
    float sAngle(sVector3D& sV3D)
    {
        // theta = cos-1(u dot v / mag (u) * mag (v))
        
        float angle = 0.0f;
        
//        std::cout << sqrtf(magnitudeSqrd()) << " " << sqrtf(sV3D.magnitudeSqrd()) << " " << std::endl;
//        float cosAngle = (sDot(sV3D)) / (sqrtf(magnitudeSqrd()) * sqrtf(sV3D.magnitudeSqrd()));

        
//        std::cout << atan2f(tan2AngleX, tan2AngleY)*180.0/M_PI << std::endl;
        
        angle = atan2f(sV3D.x, sV3D.y);
        
        //angle = acosf(cosAngle);
         
        return angle;
    }
    
    sVector3D& operator=(const sVector3D& sV3D);
};

sVector3D& sVector3D::operator=(const sVector3D& sV3D)
{
    if (this == &sV3D) return *this;
    
    else
    {    
        x = sV3D.x;
        y = sV3D.y;
        z = sV3D.z;
        
        return *this;
    }
}
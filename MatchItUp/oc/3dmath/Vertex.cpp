#include "Vertex.h"
#include <math.h>

Vertex::Vertex(float xx,float yy,float zz)
{
	x=xx;
	y=yy;
	z=zz;
}

void Vertex::setX(float xx)
{
	x=xx;
}

void Vertex::setY(float yy)
{
	y=yy;
}

void Vertex::setZ(float zz)
{
	z=zz;
}

float Vertex::getX()
{
	return x;
}

float Vertex::getY()
{
	return y;
}

float Vertex::getZ()
{
	return z;
}

float SquareDistance(Vertex a,Vertex b)
{
	float xx,yy,zz;
	xx=a.x-b.x;
	yy=a.y-b.y;
	zz=a.z-b.z;
	return xx*xx+yy*yy+zz*zz;
}

float Distance(Vertex &a,Vertex &b)
{
	float xx,yy,zz;
	xx=a.x-b.x;
	yy=a.y-b.y;
	zz=a.z-b.z;
	return sqrt(xx*xx+yy*yy+zz*zz);
}

Vertex MidVertex(Vertex a,Vertex b)
{	
	Vertex mid(0,0,0);
	mid.x = (a.x+b.x)/2;
	mid.y = (a.y+b.y)/2;
	mid.z = (a.z+b.z)/2;
	return mid;
}

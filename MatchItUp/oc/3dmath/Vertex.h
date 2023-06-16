//#ifndef __VEX_H_INCLUDED__
//#define __VEX_H_INCLUDED__

class Vertex
{
public:
	float x,y,z;
	Vertex(float xx,float yy,float zz);
	void setX(float xx);
	void setY(float yy);
	void setZ(float zz);
	float getX();
	float getY();
	float getZ();
};

float SquareDistance(Vertex a,Vertex b);
float Distance(Vertex &a,Vertex &b);
Vertex MidVertex(Vertex a,Vertex b);

/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef VERTEX_H
#define VERTEX_H

#include <Engine/Graphics/OpenGL.h>
#include <Engine/Graphics/Color.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Math/Point.h>

namespace en
{
	struct Vertex
	{
		void Draw()
		{
			glColor4f(color.r, color.g, color.b, color.a);
			glTexCoord2f(uv.x, uv.y);
			glNormal3f(normal.x, normal.y, normal.z);
			glVertex3f(point.x, point.y, point.z);
		}
		
		Vertex::Vertex() {}
		
		Vector3f point;
		Vector3f normal;
		Color color;
		Pointf uv;
	};

	typedef std::vector<Vertex> VertexList;
}

#endif
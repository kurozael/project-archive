/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef TRIANGLE_H
#define TRIANGLE_H

#include <Engine/Graphics/Vertex.h>

namespace en
{
	struct Triangle
	{
		void Draw()
		{
			for (int i = 0; i < 3; i++)
			{
				verts[i].Draw();
			}
		}

		Vertex verts[3];
	};

	typedef std::vector<Triangle> TriangleList;
}

#endif
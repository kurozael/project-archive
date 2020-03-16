/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef BBOX_H
#define BBOX_H

#include <Engine/Graphics/Color.h>
#include <Engine/Math/Vector3.h>

namespace en
{
	class BBox
	{
	public:
		BBox GetOctChild(int octant) const;
		Vector3f GetCenter() const;
		bool Contains(const Vector3f& position);
		void Draw(const Color& color, int lineSize);
		BBox(const Vector3f& minimum, const Vector3f& maximum);
		BBox(const Vector3f& position, float size);
		BBox();
		~BBox();
	public:
		Vector3f min;
		Vector3f max;
	};
}

#endif
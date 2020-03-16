/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Graphics/OpenGL.h>
#include <Engine/Graphics/Render.h>
#include <Engine/Math/LineSeg.h>
#include <Engine/Math/BBox.h>

namespace en
{
	Vector3f BBox::GetCenter() const
	{
		return (min + max) / 2.0f;
	}
	
	BBox BBox::GetOctChild(int octant) const
	{
		Vector3f center = GetCenter();
		Vector3f octMin = min;
		Vector3f octMax = max;

		if (octant & 1)
			octMin.x = center.x;
		else
			octMax.x = center.x;
			
		if (octant & 2)
			octMin.y = center.y;
		else
			octMax.y = center.y;
			
		if (octant & 4)
			octMin.z = center.z;
		else
			octMax.z = center.z;

		return BBox(octMin, octMax);
	}
	
	bool BBox::Contains(const Vector3f& position)
	{
		return (
			position.x >= min.x && position.x < max.x &&
			position.y >= min.y && position.y < max.y &&
			position.z >= min.z && position.z < max.z
		);
	}
	
	void BBox::Draw(const Color& color, int lineSize)
	{
		Render::World::LineSeg(LineSeg(
			Vector3f(min.x, min.y, min.z), 
			Vector3f(max.x, min.y, min.z)),
			color, lineSize);

		Render::World::LineSeg(LineSeg(
			Vector3f(max.x, min.y, min.z), 
			Vector3f(max.x, min.y, max.z)),
			color, lineSize);

		Render::World::LineSeg(LineSeg(
			Vector3f(max.x, min.y, max.z), 
			Vector3f(min.x, min.y, max.z)),
			color, lineSize);

		Render::World::LineSeg(LineSeg(
			Vector3f(min.x, min.y, max.z), 
			Vector3f(min.x, min.y, min.z)),
			color, lineSize);

		Render::World::LineSeg(LineSeg(
			Vector3f(min.x, max.y, min.z), 
			Vector3f(max.x, max.y, min.z)),
			color, lineSize);

		Render::World::LineSeg(LineSeg(
			Vector3f(max.x, max.y, min.z), 
			Vector3f(max.x, max.y, max.z)),
			color, lineSize);

		Render::World::LineSeg(LineSeg(
			Vector3f(max.x, max.y, max.z), 
			Vector3f(min.x, max.y, max.z)),
			color, lineSize);

		Render::World::LineSeg(LineSeg(
			Vector3f(min.x, max.y, max.z), 
			Vector3f(min.x, max.y, min.z)),
			color, lineSize);

		Render::World::LineSeg(LineSeg(
			Vector3f(min.x, min.y, min.z), 
			Vector3f(min.x, max.y, min.z)),
			color, lineSize);

		Render::World::LineSeg(LineSeg(
			Vector3f(max.x, min.y, min.z), 
			Vector3f(max.x, max.y, min.z)),
			color, lineSize);

		Render::World::LineSeg(LineSeg(
			Vector3f(max.x, min.y, max.z), 
			Vector3f(max.x, max.y, max.z)),
			color, lineSize);

		Render::World::LineSeg(LineSeg(
			Vector3f(min.x, min.y, max.z), 
			Vector3f(min.x, max.y, max.z)),
			color, lineSize);
	}
	
	BBox::BBox(const Vector3f& minimum, const Vector3f& maximum) : min(minimum), max(maximum) {}

	BBox::BBox(const Vector3f& position, float size)
	{
		Vector3f bounds = Vector3f(size, size, size) / 2.0f;
		min = position - bounds;
		max = position + bounds;
	}

	BBox::BBox() {}

	BBox::~BBox() {}
}
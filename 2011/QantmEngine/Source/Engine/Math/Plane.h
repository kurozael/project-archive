/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef PLANE_H
#define PLANE_H

#include <Engine/Math/LineSeg.h>
#include <Engine/Math/Vector3.h>

namespace en
{
	class Plane
	{
	public:
		enum Accuracy
		{
			IN_FRONT,
			BEHIND,
			EXACT
		};
	public:
		Accuracy GetAccuracy(Vector3f& position);
		float Distance(LineSeg& lineSeg);
		float Distance(Vector3f& position);
		bool IsOnPlane(const Vector3f& position);
		void Normalize();
		Plane(const Vector3f& a, const Vector3f& b, const Vector3f& c);
		Plane(const Vector3f& normal, float distance);
		Plane();
		~Plane();
	private:
		Vector3f m_normal;
		float m_distance;
	};
}

#endif
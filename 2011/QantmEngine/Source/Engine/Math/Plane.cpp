/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Math/Plane.h>
#include <algorithm>

namespace en
{
	Plane::Accuracy Plane::GetAccuracy(Vector3f& position)
	{
		float distance = Distance(position);

		if (distance > 0.0f)
			return IN_FRONT;
		else if (distance < 0.0f)
			return BEHIND;
		else
			return EXACT;
	}

	float Plane::Distance(LineSeg& lineSeg)
	{
		Vector3f startPos = lineSeg.GetStart();
		Vector3f endPos = lineSeg.GetEnd();

		if (GetAccuracy(startPos) != GetAccuracy(endPos))
			return 0.0f;

		return std::min<float>(
			Distance(startPos), Distance(endPos)
		);
	}

	float Plane::Distance(Vector3f& position)
	{
		return (position.Dot(m_normal) - m_distance);
	}

	bool Plane::IsOnPlane(const Vector3f& position)
	{
		float aX = m_normal.x * position.x;
		float aY = m_normal.y * position.y;
		float aZ = m_normal.z * position.z;
			
		return ((aX + aY + aZ) == m_distance);
	}

	void Plane::Normalize()
	{
		float length = m_normal.Length();
		float scalar = 1.0f / length;
		m_distance *= (1.0f / length);
		m_normal *= scalar;
	}

	Plane::Plane(const Vector3f& a, const Vector3f& b, const Vector3f& c)
	{
		m_normal = (b - a).Cross(c - a);
		m_distance = m_normal.Dot(a);
		Normalize();
	}

	Plane::Plane(const Vector3f& normal, float distance)
	{
		m_normal = normal;
		m_distance = distance;
		Normalize();
	}

	Plane::Plane() : m_distance(0.0f) {}

	Plane::~Plane() {}
}
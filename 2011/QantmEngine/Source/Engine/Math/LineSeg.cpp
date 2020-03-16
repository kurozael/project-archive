/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Math/LineSeg.h>
#include <math.h>

namespace en
{
	const Vector3f& LineSeg::GetStart() const
	{
		return m_start;
	}

	const Vector3f& LineSeg::GetEnd() const
	{
		return m_end;
	}

	Vector3f LineSeg::GetPoint(float fraction) const
	{
		return m_start + ((m_end - m_start) * fraction);
	}

	float LineSeg::SquaredDistance(const Vector3f& position)
	{
		Vector3f m = m_end - m_start;
		Vector3f q = position - m_start;
		float t = m.Dot(q - m_start) / m.Dot(m);

		if (t < 0)
			return (q - m_start).SquaredLength();

		if (t > 1)
			return (q - m_end).SquaredLength();

		return (q - (m_start + (m * t))).SquaredLength();
	}

	float LineSeg::Distance(const Vector3f& position)
	{
		return sqrt( SquaredDistance(position) );
	}

	LineSeg::LineSeg(const Vector3f& start, const Vector3f& end)
	{
		m_start = start;
		m_end = end;
	}

	LineSeg::LineSeg() {}

	LineSeg::~LineSeg() {}
}
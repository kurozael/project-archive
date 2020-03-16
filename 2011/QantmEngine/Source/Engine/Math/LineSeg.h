/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef LINESEG_H
#define LINESEG_H

#include <Engine/Math/Vector3.h>

namespace en
{
	class LineSeg
	{
	public:
		float SquaredDistance(const Vector3f& position);
		float Distance(const Vector3f& position);
		const Vector3f& GetStart() const;
		const Vector3f& GetEnd() const;
		Vector3f GetPoint(float fraction) const;
		LineSeg(const Vector3f& start, const Vector3f& end);
		LineSeg();
		~LineSeg();
	private:
		Vector3f m_start;
		Vector3f m_end;
	};
}

#endif
/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef QANGLE_H
#define QANGLE_H

#include <Engine/Math/Vector3.h>

namespace en
{
	class QAngle
	{
	public:
		QAngle operator*(const QAngle& rhs);
		QAngle Conjugate();
		Vector3f operator*(const Vector3f& rhs);
		float SquaredLength();
		float Length();
		void Normalize();
		void ToMatrix(float matrix[16]) const;
		QAngle(float degrees, const Vector3f& axis);
		QAngle();
		~QAngle();
	public:
		float w;
		float x;
		float y;
		float z;
	};
}

#endif
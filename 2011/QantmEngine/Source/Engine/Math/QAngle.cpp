/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifdef _WIN32
#define _USE_MATH_DEFINES
#endif

#include <Engine/Math/QAngle.h>
#include <math.h>

namespace en
{
	QAngle QAngle::operator*(const QAngle& rhs)
	{
		QAngle result;
		result.w = w * rhs.w - x * rhs.x - y * rhs.y - z * rhs.z;
		result.x = w * rhs.x + x * rhs.w + y * rhs.z - z * rhs.y;
		result.y = w * rhs.y + y * rhs.w + z * rhs.x - x * rhs.z;
		result.z = w * rhs.z + z * rhs.w + x * rhs.y - y * rhs.x;
		return result;
	};

	Vector3f QAngle::operator*(const Vector3f& rhs)
	{
		Vector3f normalized = rhs.NormalCopy();
		QAngle vecQuat, resQuat;

		vecQuat.x = normalized.x;
		vecQuat.y = normalized.y;
		vecQuat.z = normalized.z;
		vecQuat.w = 0.0f;

		resQuat = vecQuat * Conjugate();
		resQuat = *this * resQuat;

		return Vector3f(resQuat.x, resQuat.y, resQuat.z);
	};

	QAngle QAngle::Conjugate()
	{
		QAngle conjugate;
			conjugate.x = -x;
			conjugate.y = -y;
			conjugate.z = -z;
			conjugate.w = w;
		return conjugate;
	};

	float QAngle::Length()
	{
		return sqrt( SquaredLength() );
	}

	float QAngle::SquaredLength()
	{
		return (x * x) + (y * y) + (z * z) + (w * w);
	}

	void QAngle::Normalize()
	{
		float scalar = ( 1.0f / Length() );
		x *= scalar;
		y *= scalar;
		z *= scalar;
		w *= scalar;
	}

	void QAngle::ToMatrix(float pMatrix[16]) const
	{
		pMatrix[ 0] = 1.0f - 2.0f * (y * y + z * z); 
		pMatrix[ 1] = 2.0f * (x * y + z * w);
		pMatrix[ 2] = 2.0f * (x * z - y * w);
		pMatrix[ 3] = 0.0f;  

		pMatrix[ 4] = 2.0f * (x * y - z * w);  
		pMatrix[ 5] = 1.0f - 2.0f * (x * x + z * z); 
		pMatrix[ 6] = 2.0f * (z * y + x * w);  
		pMatrix[ 7] = 0.0f;  

		pMatrix[ 8] = 2.0f * (x * z + y * w);
		pMatrix[ 9] = 2.0f * (y * z - x * w);
		pMatrix[10] = 1.0f - 2.0f * (x * x + y * y);  
		pMatrix[11] = 0.0f;  

		pMatrix[12] = 0;  
		pMatrix[13] = 0;  
		pMatrix[14] = 0;  
		pMatrix[15] = 1.0f;
	}

	QAngle::QAngle(float degrees, const Vector3f& axis)
	{
		float radians = ((degrees / 180.0f) * (float)M_PI) * 0.5f;
		float sine = sin(radians);

		w = cos(radians);
		x = axis.x * sine;
		y = axis.y * sine;
		z = axis.z * sine;
	}

	QAngle::QAngle() : w(1.0f), x(0.0f), y(0.0f), z(0.0f) {}

	QAngle::~QAngle() {}
}
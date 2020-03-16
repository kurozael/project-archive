/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifdef _WIN32
#define _USE_MATH_DEFINES
#endif

#include <Engine/System/Utility.h>
#include <Engine/Math/EAngle.h>
#include <math.h>

namespace en
{
	QAngle EAngle::ToQuaternion()
	{
		if (m_cached.x != p || m_cached.y != y || m_cached.z != r)
		{
			m_cached.x = p; m_cached.y = y; m_cached.z = r;
			m_quaternion = QAngle(y, Constants::AXIS_Y) * QAngle(p, Constants::AXIS_X) * QAngle(r, Constants::AXIS_Z);
		}

		return m_quaternion;
	}

	Vector3f EAngle::Direction()
	{
		float yaw = Math::DegToRad(y);
		float roll = Math::DegToRad(r);

		return Vector3f(std::cos(yaw) * std::cos(roll),
			std::sin(-roll), std::sin(-yaw) * std::cos(roll));
	}

	Vector3f EAngle::Forward()
	{
		return ToQuaternion() * (Constants::AXIS_X * -1);
	}

	Vector3f EAngle::Right()
	{
		return ToQuaternion() * (Constants::AXIS_Z * -1);
	}

	Vector3f EAngle::Up()
	{
		return ToQuaternion() * Constants::AXIS_Y;
	}
	
	void EAngle::Unset()
	{
		glRotatef(-p, 1, 0, 0);
		glRotatef(-y, 0, 1, 0);
		glRotatef(-r, 0, 0, 1);
	}

	void EAngle::Set()
	{
		glRotatef(p, 1, 0, 0);
		glRotatef(y, 0, 1, 0);
		glRotatef(r, 0, 0, 1);
	}

	EAngle::EAngle(float pitch, float yaw, float roll) : p(pitch), y(yaw), r(roll) {}

	EAngle::EAngle() : p(0.0f), y(0.0f), r(0.0f) {}

	EAngle::~EAngle() {}
}
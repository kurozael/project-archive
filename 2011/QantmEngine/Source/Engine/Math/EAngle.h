/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef EANGLE_H
#define EANGLE_H

#include <Engine/Graphics/OpenGL.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Math/QAngle.h>

namespace en
{
	class EAngle
	{
	public:
		QAngle ToQuaternion();
		Vector3f Direction();
		Vector3f Forward();
		Vector3f Right();
		Vector3f Up();
		void Unset();
		void Set();
		EAngle(float pitch, float yaw, float roll);
		EAngle();
		~EAngle();
	private:
		Vector3f m_cached;
		QAngle m_quaternion;
	public:
		float p;
		float y;
		float r;
	};
}

#endif
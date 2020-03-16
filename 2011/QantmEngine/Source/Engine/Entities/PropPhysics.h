/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef PROPPHYSICS_H
#define PROPPHYSICS_H

#include <Engine/System/Entity.h>

namespace en
{
	class PropPhysics : public Entity
	{
	public:
		Vector3f& GetVelocity();
		void AddVelocity(Vector3f& velocity);
		void SetVelocity(Vector3f& velocity);
		EAngle& GetSpin();
		void SetSpin(EAngle& spin);
		void AddSpin(EAngle& spin);
	public:
		std::string GetClass()
		{
			return "PropPhysics";
		};
		void OnUpdate();
	public:
		virtual ~PropPhysics();
		PropPhysics();
	protected:
		Vector3f m_velocity;
		EAngle m_spin;
	};

	typedef std::shared_ptr<PropPhysics> pPropPhysics;
}

#endif
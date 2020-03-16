/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef CHASECAM_H
#define CHASECAM_H

#include <Engine/System/Entity.h>

namespace en
{
	class ChaseCam : public Entity
	{
	public:
		void OnDraw();
		void OnUpdate();
		void OnEvent(sf::Event& event);
		void SetTarget(const Vector3f& target);
		void SetDistance(float distance);
		~ChaseCam();
		ChaseCam();
	private:
		Vector3f m_target;
		float m_distance;
	};

	typedef std::shared_ptr<ChaseCam> pChaseCam;
}

#endif
/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Entities/ChaseCam.h>
#include <Engine/System/Timer.h>
#include <Engine/System/Utility.h>
#include <Engine/Game.h>

namespace en
{
	void ChaseCam::SetDistance(float distance)
	{
		m_distance = distance;
	}

	void ChaseCam::SetTarget(const Vector3f& target)
	{
		m_target = target;
	}

	void ChaseCam::OnEvent(sf::Event& event) {}

	void ChaseCam::OnUpdate()
	{
		float camChase = 4.0f * Timer::GetDT();

		m_position.x = Math::Approach(m_position.x, m_target.x, camChase);
		m_position.z = Math::Approach(m_position.z, m_target.z, camChase);

		OpenGL::LookAt(
			m_position + Vector3f(0, m_distance, 0), m_position, Vector3f(0, 0, -1)
		);
	}

	void ChaseCam::OnDraw() {}

	ChaseCam::ChaseCam() : m_distance(20.0f) {}

	ChaseCam::~ChaseCam() {}
}
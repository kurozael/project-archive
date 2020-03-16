/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Entities/MoveCam.h>
#include <Engine/System/Timer.h>
#include <Engine/Game.h>

namespace en
{
	void MoveCam::SetLookAt()
	{
		Vector3f camUp = m_angle.Up();
		Vector3f& camDir = m_angle.Direction();
		Vector3f camPos = m_position + (camDir * 3);
		Vector3f camEnd = m_position + (camDir * -3);

		OpenGL::LookAt(camPos, camEnd, Vector3f(0, camUp.y, 0));
	}

	void MoveCam::OnEvent(sf::Event& event) {}

	void MoveCam::OnUpdate()
	{
		float moveSpeed = 64.0f * Timer::GetDT();

		if (sf::Keyboard::IsKeyPressed(sf::Keyboard::W))
		{
			m_position = m_position + (m_angle.Direction() * -moveSpeed);
		}
		else if (sf::Keyboard::IsKeyPressed(sf::Keyboard::S))
		{
			m_position = m_position + (m_angle.Direction() * moveSpeed);
		}

		if (sf::Keyboard::IsKeyPressed(sf::Keyboard::A))
		{
			m_angle.y += moveSpeed;
		}
		else if (sf::Keyboard::IsKeyPressed(sf::Keyboard::D))
		{
			m_angle.y -= moveSpeed;
		}

		if (sf::Keyboard::IsKeyPressed(sf::Keyboard::Up))
		{
			m_angle.r += moveSpeed;
		}
		else if (sf::Keyboard::IsKeyPressed(sf::Keyboard::Down))
		{
			m_angle.r -= moveSpeed;
		}
	}

	void MoveCam::OnDraw() {}

	MoveCam::MoveCam() {}

	MoveCam::~MoveCam() {}
}
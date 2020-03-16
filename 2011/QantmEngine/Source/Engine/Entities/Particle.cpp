/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Entities/Particle.h>
#include <Engine/System/Timer.h>
#include <Engine/System/Asset.h>
#include <Engine/System/Utility.h>
#include <Engine/Game.h>

namespace en
{
	void Particle::SetAirResistance(float airResistance)
	{
		m_airResistance = Math::Clamp(0.9f + (airResistance / 10.0f), 0.9f, 0.99f);
	}

	void Particle::SetTexture(const std::string& fileName)
	{
		m_billboard.SetTexture(fileName);
	}
	
	void Particle::SetVelocity(Vector3f& velocity)
	{
		m_velocity = velocity;
	}
	
	void Particle::SetDieTime(float dieTime)
	{
		m_dieTime = Timer::CurTime() + dieTime;
		m_duration = dieTime;
	}
	
	void Particle::SetStartSize(float startSize)
	{
		m_startSize = startSize;
	}
	
	void Particle::SetEndSize(float endSize)
	{
		m_endSize = endSize;
	}

	void Particle::SetStartAlpha(float startAlpha)
	{
		m_startAlpha = startAlpha;
	}

	void Particle::SetEndAlpha(float endAlpha)
	{
		m_endAlpha = endAlpha;
	}
	
	bool Particle::IsFinished()
	{
		return Timer::CurTime() > m_dieTime;
	}

	void Particle::SetColor(Color& color)
	{
		m_color = color;
	}

	void Particle::OnEvent(sf::Event& event) {}

	void Particle::OnUpdate()
	{
		float deltaTime = Timer::GetDT();
		m_position = m_position + (m_velocity * deltaTime);
		m_velocity *= m_airResistance;
	}

	void Particle::OnDraw()
	{
		if ( IsFinished() )
			return;
		
		float timeLeft = m_dieTime - Timer::CurTime();
		float alpha = m_startAlpha + ( ( (m_endAlpha - m_startAlpha) / m_duration ) * (m_duration - timeLeft) );
		float size = m_startSize + ( ( (m_endSize - m_startSize) / m_duration ) * (m_duration - timeLeft) );
		
		glPushMatrix();
			glColor4f(m_color.r, m_color.g, m_color.b, alpha);
				m_billboard.Draw(m_position, size);
			glColor4f(1, 1, 1, 1);
		glPopMatrix();
	}

	Particle::Particle()
	{
		m_startTime = Timer::CurTime();
		m_billboard.SetTexture("textures/particle.png");
		m_airResistance = 0.98f;
		m_startAlpha = 1.0f;
		m_endAlpha = 0.0f;
		m_startSize = 64.0f;
		m_duration = 1.0f;
		m_endSize = 0.0f;
		m_dieTime = m_startTime + 1.0f;
	}

	Particle::~Particle() {}
}
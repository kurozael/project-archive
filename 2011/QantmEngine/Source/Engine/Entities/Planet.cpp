/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Entities/Planet.h>
#include <Engine/Graphics/Render.h>
#include <Engine/System/Utility.h>
#include <Engine/System/Timer.h>
#include <Engine/System/Asset.h>
#include <Engine/System/Events.h>
#include <Engine/Math/Physics.h>
#include <Engine/Game.h>

namespace en
{
	void Planet::OnEvent(sf::Event& event) {}

	void Planet::OnUpdate()
	{
		float curTime = Timer::CurTime();
		float sineWave = std::abs( std::sin(curTime) );
		float velMax = (m_size * 3.0f);

		if (m_clockwise)
			m_angle.y -= 64.0f * Timer::GetDT();
		else
			m_angle.y += 64.0f * Timer::GetDT();

		for (int i = 0; i < 2; i++)
		{
			float airResistance = Math::Random(0.5f, 0.9f);
			float startSize = Math::Random(0.1f, 0.5f);
			float endSize = Math::Random(0.0f, 0.1f);
			float dieTime = Math::Random(0.0f, 2.0f);
			float randomX = Math::Random(-velMax, velMax);
			float randomY = Math::Random(-velMax, velMax);
			float randomZ = Math::Random(-velMax, velMax);
			std::string texture = "textures/star.png";

			if (Math::Random(1.0f, 4.0f) <= 2.0f)
				texture = "textures/heart.png";

			pParticle particle = m_emitter->New();
			particle->SetPos(m_position);
			particle->SetDieTime(dieTime);
			particle->SetStartSize(startSize);
			particle->SetTexture(texture);
			particle->SetEndSize(endSize);
			particle->SetVelocity(Vector3f(randomX, randomY, randomZ));
			particle->SetAirResistance(airResistance);
			m_emitter->Add(particle);
		}

		m_emitter->Update();
	}

	bool Planet::IsClockwise()
	{
		return m_clockwise;
	}

	void Planet::SetSize(float size)
	{
		m_size = size;
	}

	float Planet::GetSize()
	{
		return m_size;
	}

	void Planet::OnDraw()
	{
		float sineWave = std::abs(std::sin(Timer::CurTime()));

		glPushMatrix();
			glColor4f(0.3, 1, 0.3, 0.25 + (0.25f * sineWave));
			glTranslatef(m_position.x, m_position.y, m_position.z);
			m_billboard.Draw(Vector3f(0.0f, 0.0f, 0.0f), (m_size * 3.0f) + (1.0f * sineWave));
			glColor4f(1, 1, 1, 1);
			m_angle.Set();
			glRotatef(90, 1, 0, 0);
			m_texture->Bind();
			Render::World::Sphere(m_size, 32, 32);
			m_texture->Unbind();
		glPopMatrix();

		m_emitter->Draw();
	}

	Planet::Planet() : m_size(2.0f), m_clockwise(false)
	{
		Singleton<Events>::Get()->Add(this);
		Singleton<Physics>::Get()->Add(this);
		
		m_billboard.SetTexture("textures/particle.png");
		m_texture = Asset<Texture>::Grab("textures/globe.jpg");
		m_emitter.reset(new Emitter);
		m_emitter->Clear();

		if (Math::Random(0.0f, 1.0f) >= 0.5f)
		{
			m_clockwise = true;
		}
	}

	Planet::~Planet()
	{
		Singleton<Events>::Get()->Remove(this);
		Singleton<Physics>::Get()->Remove(this);
	}
}
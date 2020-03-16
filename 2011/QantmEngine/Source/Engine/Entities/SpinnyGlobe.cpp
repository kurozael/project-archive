/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Entities/SpinnyGlobe.h>
#include <Engine/System/Utility.h>
#include <Engine/System/Timer.h>
#include <Engine/System/Asset.h>
#include <Engine/Game.h>

namespace en
{
	void SpinnyGlobe::OnEvent(sf::Event& event) {}

	void SpinnyGlobe::OnUpdate()
	{
		float curTime = Timer::CurTime();
		float sineWave = std::abs( std::sin(curTime) );
		m_angle.y += 64.0f * Timer::GetDT();

		if (curTime >= m_nextParticles && sineWave > 0.9f)
		{
			m_nextParticles = curTime + 2;

			for (int i = 0; i < 64; i++)
			{
				float airResistance = Math::Random(0.5f, 0.9f);
				float startSize = Math::Random(4.0f, 32.0f);
				float endSize = Math::Random(0.0f, 8.0f);
				float dieTime = Math::Random(2.0f, 3.0f);
				float randomX = Math::Random(-200.0f, 200.0f);
				float randomY = Math::Random(-200.0f, 200.0f);
				float randomZ = Math::Random(-200.0f, 200.0f);
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
		}

		m_emitter->Update();

		m_light->SetRadius(300.0f * sineWave);
		m_light->SetPos(m_position);
		m_light->Update();
	}

	void SpinnyGlobe::OnDraw()
	{
		float sineWave = std::abs( std::sin( Timer::CurTime() ) );

		glPushMatrix();
			glColor4f(0.3, 1, 0.3, 0.75 * sineWave);
			glTranslatef(m_position.x, m_position.y, m_position.z);
			m_billboard.Draw(Vector3f(0.0f, 0.0f, 0.0f), 96.0f * sineWave);
			glColor4f(1, 1, 1, 1);
			m_angle.Set();
			glRotatef(90, 1, 0, 0);
			glScalef(0.5 * sineWave, 0.5 * sineWave, 0.5 * sineWave);
			m_staticMesh->Draw();
		glPopMatrix();

		m_emitter->Draw();
	}

	SpinnyGlobe::SpinnyGlobe()
	{
		m_staticMesh = Asset<StaticMesh>::Grab("meshes/globe.obj");
		
		m_billboard.SetTexture("textures/particle.png");
		m_emitter.reset(new Emitter);
		m_emitter->Clear();

		m_light.reset(new Light);
		m_light->SetLightType(GL_LIGHT1);
		m_light->SetEnabled(true);
		m_light->SetDiffuse(Color(0, 1, 0));
		m_light->SetAmbient(Color(0, 1, 0));
		m_light->SetRadius(300.0f);
	}

	SpinnyGlobe::~SpinnyGlobe() {}
}
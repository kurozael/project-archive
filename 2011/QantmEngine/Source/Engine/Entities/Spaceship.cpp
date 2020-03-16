/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Entities/Spaceship.h>
#include <Engine/System/Timer.h>
#include <Engine/Math/Physics.h>
#include <Engine/System/Events.h>
#include <Engine/System/Asset.h>
#include <Engine/System/Utility.h>
#include <Engine/Graphics/Render.h>
#include <Engine/Game.h>

namespace en
{
	bool Spaceship::DoesCollide(pEntity& other)
	{
		if (other->GetClass() != "Planet" || m_velocity.Length() == 0.0f)
			return false;

		Planet* planet = dynamic_cast<Planet*>(other.get());

		if (planet == m_planet)
			return false;

		float distance = planet->GetPos().Distance(m_position);
		float size = planet->GetSize();

		/* Are we close enough to this planet to be pulled in by gravity? */
		if (distance <= size * 3.0f)
		{
			Vector3f& position = planet->GetPos();
			Vector3f direction = position - m_position;

			if (distance <= size * 2.0f)
				SetVelocity(direction * 2.0f);

			// Face the planet that is pulling us in...
			float angle = std::atan2(direction.z, -direction.x);
				angle = (angle * 180.f) / M_PI;
			m_angle.y = Math::Approach(m_angle.y, angle, Timer::GetDT() * 270.0f);
		}

		// Add radius of ship :)
		return (distance <= size + 0.8f);
	}

	void Spaceship::OnCollision(pEntity& collider)
	{
		if (collider->GetClass() == "Planet"
			&& dynamic_cast<Planet*>(collider.get()) != m_planet)
		{
			SetPlanet(dynamic_cast<Planet*>(collider.get()));
			SetVelocity(Vector3f(0, 0, 0));
		}
	}

	void Spaceship::SetPlanet(Planet* planet)
	{
		Vector3f& position = planet->GetPos();
		Vector3f direction = position - m_position;
		float angle = std::atan2(direction.z, -direction.x);

		m_orbit = angle;
		m_planet = planet;
		m_fuel = 100.0f;
	}

	Planet* Spaceship::GetPlanet()
	{
		return m_planet;
	}

	void Spaceship::OnEvent(sf::Event& event)
	{
		if (event.Type == sf::Event::KeyPressed && event.Key.Code == sf::Keyboard::Space
			&& m_velocity.Length() == 0)
		{
			Jump();
		}
	}

	void Spaceship::OnUpdate()
	{
		if (m_planet != nullptr && m_velocity.Length() == 0)
		{
			Vector3f& position = m_planet->GetPos();
			Vector3f direction = position - m_position;
			float angle = std::atan2(direction.z, -direction.x);
			float size = m_planet->GetSize() + 1.0f;
			angle = (angle * 180.f) / M_PI;

			m_position.x = position.x + std::cos(m_orbit) * size;
			m_position.z = position.z - std::sin(m_orbit) * size;
			m_angle.y = angle;
			
			if (m_planet->IsClockwise())
				m_orbit -= (Timer::GetDT() * 2.0f);
			else
				m_orbit += (Timer::GetDT() * 2.0f);
		}
		else
		{
			PropPhysics::OnUpdate();

			if (m_fuel > 0.0f)
			{
				m_fuel = std::max<float>(m_fuel - (Timer::GetDT() * 16.0f), 0);
			}
			else
			{
				// EXPLODE! ExplodeParticles()?
			}
		}

		m_light->SetPos(m_position);
		m_light->Update();
	}

	void Spaceship::OnDraw()
	{
		glPushMatrix();
			glTranslatef(m_position.x, m_position.y, m_position.z);
			glColor4f(0.3, 0.3, 1, 0.5);
			m_billboard.Draw(Vector3f(0.0f, 0.0f, 0.0f), 5.0f);
			m_angle.Set();
			glColor4f(1, 1, 1, 1);
			glRotatef(270, 1, 0, 0);
			glScalef(0.03, 0.03, 0.03);
			m_staticMesh->Draw();
		glPopMatrix();

		// Don't display the fuel bar if we're orbiting!
		if (m_velocity.SquaredLength() == 0.0f)
			return;

		Pointf screenPos = Render::ToScreen(m_position);

		// Position the fuel bar above the spaceship.
		screenPos.y -= 64.0f;

		Render::Start2D();
			Render::Screen::Quad(screenPos.x, screenPos.y, 64, 6, Color(1, 0.2, 0.2, 1));
			Render::Screen::Quad(screenPos.x, screenPos.y, (64.0f / 100.0f) * m_fuel, 6, Color(0, 1, 0, 1));
			
			Render::Font::Start("Appleberry");
				Render::Font::Draw(screenPos.x, screenPos.y + 8, 20, "FUEL: " + Math::ToString(std::ceil(m_fuel)), Constants::WHITE);
			Render::Font::End();
		Render::End2D();
	}

	float Spaceship::GetFuel()
	{
		return m_fuel;
	}

	void Spaceship::Jump()
	{
		SetVelocity(m_angle.Direction() * 4);
	}

	Spaceship::Spaceship()
	{
		m_staticMesh = Asset<StaticMesh>::Grab("meshes/spaceship.obj");
		m_billboard.SetTexture("textures/particle.png");

		m_light.reset(new Light);
		m_light->SetLightType(GL_LIGHT1);
		m_light->SetEnabled(true);
		m_light->SetDiffuse(Color(0, 0, 1));
		m_light->SetRadius(6.0f);

		Singleton<Physics>::Get()->Add(this);
		Singleton<Events>::Get()->Add(this);

		m_fuel = 100.0f;
	}

	Spaceship::~Spaceship()
	{
		Singleton<Events>::Get()->Remove(this);
		Singleton<Physics>::Get()->Remove(this);
	}
}
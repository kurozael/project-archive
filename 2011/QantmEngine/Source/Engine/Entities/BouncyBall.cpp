/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Entities/BouncyBall.h>
#include <Engine/Graphics/Render.h>
#include <Engine/Math/Physics.h>
#include <Engine/System/Utility.h>
#include <Engine/System/Timer.h>
#include <Engine/System/Asset.h>
#include <Engine/Game.h>

namespace en
{
	void BouncyBall::SetSquareRoom(SquareRoom* squareRoom)
	{
		m_squareRoom = squareRoom;

	}

	bool BouncyBall::DoesCollide(pEntity& other)
	{
		if (other->GetClass() == "BouncyBall")
		{
			BouncyBall* ball = (BouncyBall*)other.get();
			return (ball->GetPos().Distance(m_position) <= m_size + ball->GetSize());
		}

		return false;
	}

	void BouncyBall::OnCollision(pEntity& collider)
	{
		if (collider->GetClass() == "BouncyBall")
		{
			BouncyBall* ball = (BouncyBall*)collider.get();
			Vector3f direction = (ball->GetPos() - m_position);
			direction.Normalize();

			float velocity = ball->GetVelocity().Length();
			float spin = velocity * 0.5f;
			float size = ball->GetSize();

			ball->SetPos(m_position + (direction * (m_size + size)));
			ball->AddSpin( EAngle(direction.x * -spin, direction.y * -spin, direction.z * -spin) );
			ball->SetVelocity(direction * (velocity * 0.9f));
			ball->EmitParticles();

			AddVelocity(direction * -(velocity * 0.1f));
			AddSpin( EAngle(direction.x * spin, direction.y * spin, direction.z * spin) );
		}
	}

	void BouncyBall::AddVelocity(Vector3f& velocity)
	{
		m_velocity = m_velocity + velocity;
	}

	Vector3f& BouncyBall::GetVelocity()
	{
		return m_velocity;
	}

	void BouncyBall::SetVelocity(Vector3f& velocity)
	{
		m_velocity = velocity;
	}

	void BouncyBall::EmitParticles()
	{
		for (int i = 0; i < 8; i++)
		{
			float airResistance = Math::Random(0.5f, 0.9f);
			float startSize = Math::Random(4.0f, 10.0f);
			float endSize = Math::Random(0.0f, 4.0f);
			float dieTime = Math::Random(2.0f, 3.0f);
			float randomX = Math::Random(-100.0f, 100.0f);
			float randomY = Math::Random(-100.0f, 100.0f);
			float randomZ = Math::Random(-100.0f, 100.0f);

			pParticle particle = m_emitter->New();
				particle->SetPos(m_position);
				particle->SetColor(m_color);
				particle->SetDieTime(dieTime);
				particle->SetStartSize(startSize);
				particle->SetEndSize(endSize);
				particle->SetVelocity(Vector3f(randomX, randomY, randomZ));
				particle->SetAirResistance(airResistance);
			m_emitter->Add(particle);
		}
	}

	EAngle& BouncyBall::GetSpin()
	{
		return m_spin;
	}

	void BouncyBall::AddSpin(EAngle& spin)
	{
		m_spin.p += spin.p;
		m_spin.y += spin.y;
		m_spin.r += spin.r;
	}

	void BouncyBall::SetColor(Color& color)
	{
		m_color = color;
	}

	void BouncyBall::SetSpin(EAngle& spin)
	{
		m_spin = spin;
	}

	float BouncyBall::GetSize() const
	{
		return m_size;
	}

	void BouncyBall::SetSize(float size)
	{
		m_size = size;
	}

	void BouncyBall::OnEvent(sf::Event& event) {}

	void BouncyBall::OnUpdate()
	{
		m_position = m_position + (m_velocity * Timer::GetDT());
		m_angle.p += m_spin.p * Timer::GetDT();
		m_angle.y += m_spin.y * Timer::GetDT();
		m_angle.r += m_spin.r * Timer::GetDT();

		float roomSize = m_squareRoom->GetSize();
		bool bCollided = false;
		float size = m_size;

		if (m_position.x - m_size < -roomSize)
		{
			m_position.x = (-roomSize + m_size);
			m_velocity.x *= -0.98f;
			bCollided = true;
		}
		else if (m_position.x + m_size > roomSize)
		{
			m_position.x = (roomSize - m_size);
			m_velocity.x *= -0.98f;
			bCollided = true;
		}

		if (m_position.y - m_size < -roomSize)
		{
			m_position.y = (-roomSize + m_size);
			m_velocity.y *= -0.98f;
			bCollided = true;
		}
		else if (m_position.y + m_size > roomSize)
		{
			m_position.y = (roomSize - m_size);
			m_velocity.y *= -0.98f;
			bCollided = true;
		}

		if (m_position.z - m_size < -roomSize)
		{
			m_position.z = (-roomSize + m_size);
			m_velocity.z *= -0.98f;
			bCollided = true;
		}
		else if (m_position.z + m_size > roomSize)
		{
			m_position.z = (roomSize - m_size);
			m_velocity.z *= -0.98f;
			bCollided = true;
		}

		if (bCollided && m_velocity.y < -32.0f)
			EmitParticles();
		
		m_velocity.y -= 8.0f;
		m_velocity *= 0.98f;
		m_spin.p *= 0.97f;
		m_spin.y *= 0.97f;
		m_spin.r *= 0.97f;

		m_emitter->Update();
	}

	void BouncyBall::OnDraw()
	{
		pMaterial sphereMap = Asset<Material>::Grab("textures/globe.jpg");

		glPushMatrix();
			glTranslatef(m_position.x, m_position.y, m_position.z);
			glColor3f(m_color.r, m_color.g, m_color.b);
				m_billboard.Draw(Vector3f(0.0f, 0.0f, 0.0f), m_size * 3.0f);
			glColor3f(1, 1, 1);
			
			m_angle.Set();
			sphereMap->Bind();
				Render::World::Sphere(m_size, 16.0f, 16.0f);
			sphereMap->Unbind();
		glPopMatrix();

		m_emitter->Draw();
	}

	BouncyBall::BouncyBall()
	{
		Singleton<Physics>::Get()->Add(this);

		m_billboard.SetTexture("textures/particle.png");
		m_emitter.reset(new Emitter);
		m_emitter->Clear();
		m_squareRoom = NULL;
		m_size = 8.0f;	
	}

	BouncyBall::~BouncyBall()
	{
		Singleton<Physics>::Get()->Remove(this);
	}
}
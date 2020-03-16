/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Entities/PropPhysics.h>
#include <Engine/Graphics/Render.h>
#include <Engine/Math/Physics.h>
#include <Engine/System/Utility.h>
#include <Engine/System/Timer.h>
#include <Engine/System/Asset.h>
#include <Engine/Game.h>

namespace en
{
	void PropPhysics::AddVelocity(Vector3f& velocity)
	{
		m_velocity = m_velocity + velocity;
	}

	Vector3f& PropPhysics::GetVelocity()
	{
		return m_velocity;
	}

	void PropPhysics::SetVelocity(Vector3f& velocity)
	{
		m_velocity = velocity;
	}
	
	EAngle& PropPhysics::GetSpin()
	{
		return m_spin;
	}

	void PropPhysics::AddSpin(EAngle& spin)
	{
		m_spin.p += spin.p;
		m_spin.y += spin.y;
		m_spin.r += spin.r;
	}

	void PropPhysics::SetSpin(EAngle& spin)
	{
		m_spin = spin;
	}
	
	void PropPhysics::OnUpdate()
	{
		m_position = m_position + (m_velocity * Timer::GetDT());
		m_angle.p += m_spin.p * Timer::GetDT();
		m_angle.y += m_spin.y * Timer::GetDT();
		m_angle.r += m_spin.r * Timer::GetDT();
		m_velocity *= 0.98f;
		m_spin.p *= 0.97f;
		m_spin.y *= 0.97f;
		m_spin.r *= 0.97f;
	}
	PropPhysics::PropPhysics() {}

	PropPhysics::~PropPhysics() {}
}
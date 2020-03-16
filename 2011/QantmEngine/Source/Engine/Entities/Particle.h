/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef PARTICLE_H
#define PARTICLE_H

#include <Engine/Graphics/Billboard.h>
#include <Engine/System/Entity.h>
#include <Engine/Math/Vector3.h>
#include <memory>
#include <string>

namespace en
{
	class Particle : public Entity
	{
	public:
		void OnDraw();
		void OnUpdate();
		void OnEvent(sf::Event& event);
		void SetAirResistance(float airResistance);
		void SetTexture(const std::string& fileName);
		void SetVelocity(Vector3f& velocity);
		void SetDieTime(float dieTime);
		void SetStartSize(float startSize);
		void SetEndSize(float endSize);
		void SetStartAlpha(float startAlpha);
		void SetEndAlpha(float endAlpha);
		void SetColor(Color& color);
		bool IsFinished();
		~Particle();
		Particle();
	private:
		Vector3f m_velocity;
		Billboard m_billboard;
		float m_airResistance;
		float m_startAlpha;
		float m_endAlpha;
		float m_startSize;
		float m_duration;
		float m_startTime;
		float m_endSize;
		float m_dieTime;
		Color m_color;
	};

	typedef std::shared_ptr<Particle> pParticle;
}

#endif
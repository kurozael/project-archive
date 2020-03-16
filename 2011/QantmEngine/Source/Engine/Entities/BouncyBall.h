/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef BOUNCYBALL_H
#define BOUNCYBALL_H

#include <Engine/Entities/SquareRoom.h>
#include <Engine/Graphics/Emitter.h>
#include <Engine/Graphics/Light.h>
#include <Engine/Graphics/Color.h>
#include <Engine/System/Entity.h>
#include <Engine/Graphics/Shader.h>

namespace en
{
	class BouncyBall : public Entity
	{
	public:
		void SetSquareRoom(SquareRoom* squareRoom);
		Vector3f& GetVelocity();
		void AddVelocity(Vector3f& velocity);
		void SetVelocity(Vector3f& velocity);
		void EmitParticles();
		void SetColor(Color& color);
		EAngle& GetSpin();
		void SetSpin(EAngle& spin);
		void AddSpin(EAngle& spin);
		float GetSize() const;
		void SetSize(float size);
	public:
		void OnDraw();
		void OnUpdate();
		void OnEvent(sf::Event& event);
		void OnCollision(pEntity& collider);
		bool DoesCollide(pEntity& other);
		std::string GetClass()
		{
			return "BouncyBall";
		};
		~BouncyBall();
		BouncyBall();
	private:
		SquareRoom* m_squareRoom;
		Billboard m_billboard;
		pEmitter m_emitter;
		Vector3f m_velocity;
		Color m_color;
		EAngle m_spin;
		float m_size;
	};

	typedef std::shared_ptr<BouncyBall> pBouncyBall;
}

#endif
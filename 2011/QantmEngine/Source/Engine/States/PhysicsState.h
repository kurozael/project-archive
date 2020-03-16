/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef PHYSICSSTATE_H
#define PHYSICSSTATE_H

#include <Engine/Entities/SquareRoom.h>
#include <Engine/Entities/MoveCam.h>
#include <Engine/Graphics/RTarget.h>
#include <Engine/Graphics/Light.h>
#include <Engine/Graphics/Shader.h>
#include <Engine/System/State.h>

/*
	Include the SFML graphics library for
	testing the shader functionality.
*/

#include <Engine/System/Singleton.h>
#include <SFML/Graphics.hpp>

namespace en
{
	class PhysicsState : public State
	{
	public:
		void LoadBalls();
		void OnLoad();
		void OnUnload();
		void OnDraw();
		void OnPaint();
		void OnUpdate();
		void OnEvent(sf::Event& event);
		~PhysicsState();
		PhysicsState();
	private:
		SquareRoom* m_squareRoom;
		RTarget m_targetX;
		RTarget m_targetY;
		Shader m_blurX;
		Shader m_blurY;
		MoveCam* m_moveCam;
		Light* m_light;
	};
}

#endif
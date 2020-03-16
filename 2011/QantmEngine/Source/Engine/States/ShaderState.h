/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef SHADERSTATE_H
#define SHADERSTATE_H

#include <Engine/Entities/SpinnyGlobe.h>
#include <Engine/Entities/SquareRoom.h>
#include <Engine/Entities/MoveCam.h>
#include <Engine/Graphics/Shader.h>
#include <Engine/Graphics/Light.h>
#include <Engine/System/State.h>

namespace en
{
	class ShaderState : public State
	{
	public:
		void OnLoad();
		void OnUnload();
		void OnDraw();
		void OnPaint();
		void OnUpdate();
		void OnEvent(sf::Event& event);
		~ShaderState();
		ShaderState();
	private:
		SquareRoom* m_squareRoom;
		MoveCam* m_moveCam;
		Shader m_shader;
		Light* m_light;
	};
}

#endif
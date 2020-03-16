/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef PLAYINGSTATE_H
#define PLAYINGSTATE_H

#include <Engine/Entities/Spaceship.h>
#include <Engine/Entities/ChaseCam.h>
#include <Engine/Graphics/RTarget.h>
#include <Engine/Graphics/Light.h>
#include <Engine/Graphics/Shader.h>
#include <Engine/System/State.h>
#include <list>

namespace en
{
	class PlayingState : public State
	{
	public:
		void OnLoad();
		void OnUnload();
		void OnDraw();
		void OnPaint();
		void OnUpdate();
		void OnEvent(sf::Event& event);
		void DrawGlow(float x, float y, float size, const std::string& text);
		~PlayingState();
		PlayingState();
	private:
		Spaceship* m_spaceship;
		ChaseCam* m_chaseCam;
		RTarget* m_fbObjectX;
		RTarget* m_fbObjectY;
		Shader m_blurX;
		Shader m_blurY;
		Light* m_light;
	};
}

#endif
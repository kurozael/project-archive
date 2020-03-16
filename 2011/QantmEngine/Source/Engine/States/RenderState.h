/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef RENDERSTATE_H
#define RENDERSTATE_H

#include <Engine/Entities/SpinnyGlobe.h>
#include <Engine/Entities/SquareRoom.h>
#include <Engine/Entities/MoveCam.h>
#include <Engine/Graphics/Light.h>
#include <Engine/System/State.h>

namespace en
{
	class RenderState : public State
	{
	public:
		void OnLoad();
		void OnUnload();
		void OnDraw();
		void OnPaint();
		void OnUpdate();
		void OnEvent(sf::Event& event);
		~RenderState();
		RenderState();
	private:
		SpinnyGlobe* m_spinnyGlobe;
		SquareRoom* m_squareRoom;
		MoveCam* m_moveCam;
		Light* m_light;
	};
}

#endif
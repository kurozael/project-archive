/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef PLANET_H
#define PLANET_H

#include <Engine/Entities/PropPhysics.h>
#include <Engine/Graphics/Billboard.h>
#include <Engine/Graphics/Emitter.h>
#include <Engine/System/Entity.h>

namespace en
{
	class Planet : public PropPhysics
	{
	public:
		std::string GetClass()
		{
			return "Planet";
		};
	public:
		void OnDraw();
		void OnUpdate();
		void OnEvent(sf::Event& event);
		void SetSize(float size);
		float GetSize();
		bool IsClockwise();
		~Planet();
		Planet();
	private:
		Billboard m_billboard;
		pTexture m_texture;
		pEmitter m_emitter;
		bool m_clockwise;
		float m_size;
	};

	typedef std::shared_ptr<Planet> pPlanet;
}

#endif
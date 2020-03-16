/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef SPINNYGLOBE_H
#define SPINNYGLOBE_H

#include <Engine/Graphics/Billboard.h>
#include <Engine/Graphics/StaticMesh.h>
#include <Engine/Graphics/Emitter.h>
#include <Engine/Graphics/Light.h>
#include <Engine/System/Entity.h>

namespace en
{
	class SpinnyGlobe : public Entity
	{
	public:
		void OnDraw();
		void OnUpdate();
		void OnEvent(sf::Event& event);
		~SpinnyGlobe();
		SpinnyGlobe();
	private:
		pStaticMesh m_staticMesh;
		Billboard m_billboard;
		float m_nextParticles;
		pEmitter m_emitter;
		pLight m_light;
	};

	typedef std::shared_ptr<SpinnyGlobe> pSpinnyGlobe;
}

#endif
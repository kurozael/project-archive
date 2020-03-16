/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef SPACESHIP_H
#define SPACESHIP_H

#include <Engine/Entities/PropPhysics.h>
#include <Engine/Graphics/StaticMesh.h>
#include <Engine/Graphics/Billboard.h>
#include <Engine/Entities/Planet.h>
#include <Engine/Graphics/Light.h>
#include <Engine/System/Entity.h>

namespace en
{
	class Spaceship : public PropPhysics
	{
	public:
		void OnCollision(pEntity& collider);
		bool DoesCollide(pEntity& other);
		std::string GetClass()
		{
			return "Spaceship";
		};
	public:
		void OnDraw();
		void OnUpdate();
		void OnEvent(sf::Event& event);
		void SetPlanet(Planet* planet);
		Planet* GetPlanet();
		float GetFuel();
		void Jump();
		~Spaceship();
		Spaceship();
	private:
		pStaticMesh m_staticMesh;
		Billboard m_billboard;
		Planet* m_planet;
		pLight m_light;
		float m_orbit;
		float m_fuel;
	};

	typedef std::shared_ptr<Spaceship> pSpaceship;
}

#endif
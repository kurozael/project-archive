/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef EVENTS_H
#define EVENTS_H

#include <Engine/System/Singleton.h>
#include <Engine/System/Component.h>
#include <SFML/Window.hpp>
#include <list>

namespace en
{
	class Events
	{
	public:
		void Handle(sf::Event& event);
		void Remove(Component* component);
		void Add(Component* component);
		~Events();
		Events();
	private:
		std::list<pComponent> m_components;
	};
}

#endif
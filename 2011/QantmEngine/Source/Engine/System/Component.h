/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef COMPONENT_H
#define COMPONENT_H

#include <SFML/Window.hpp>
#include <memory>

namespace en
{
	class Component
	{
	public:
		virtual void OnDraw() = 0;
		virtual void OnUpdate() = 0;
		virtual void OnPaint() {};
		virtual void OnEvent(sf::Event& event) {};
		virtual ~Component() {};
	};

	typedef std::shared_ptr<Component> pComponent;
}

#endif
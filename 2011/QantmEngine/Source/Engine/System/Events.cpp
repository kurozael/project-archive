/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/System/Events.h>

namespace en
{
	void Events::Handle(sf::Event& event)
	{
		std::list<pComponent>::iterator it;

		for (it = m_components.begin(); it != m_components.end(); it++)
		{
			pComponent component = *it;
			if (component != nullptr)
				component->OnEvent(event);
		}
	}
	
	void Events::Remove(Component* component)
	{
		std::list<pComponent>::iterator it = m_components.begin();

		while (it != m_components.end())
		{
			pComponent ptr = *it; it++;
			if (ptr.get() == component)
				m_components.remove(ptr);
		}
	}
	
	void Events::Add(Component* component)
	{
		pComponent sharedPtr = pComponent(component);
		m_components.push_back(sharedPtr);
	}

	Events::Events() {}

	Events::~Events() {}
}
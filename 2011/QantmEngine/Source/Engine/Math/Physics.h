/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef COLLISIONS_H
#define COLLISIONS_H

#include <Engine/System/Singleton.h>
#include <Engine/System/Entity.h>
#include <list>

namespace en
{
	class Physics
	{
	public:
		EntityList& GetEntities();
		void Remove(Entity* entity);
		void Update();
		void Clear();
		void Add(Entity* entity);
		Physics();
		~Physics();
	private:
		EntityList m_entities;
		EntityList m_delQueue;
	};
}

#endif
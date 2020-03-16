/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Math/Physics.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Math/BBox.h>

namespace en
{
	EntityList& Physics::GetEntities()
	{
		return m_entities;
	}

	void Physics::Remove(Entity* entity)
	{
		EntityList::iterator it = m_entities.begin();

		while (it != m_entities.end())
		{
			pEntity ptr = *it; it++;
			if (ptr.get() == entity)
				m_entities.remove(ptr);
		}
	}
	
	void Physics::Update()
	{
		EntityList::iterator a = m_entities.begin();
		
		while (a != m_entities.end())
		{
			pEntity first = *a; a++;

			if (first == nullptr)
				continue;
			
			EntityList::iterator b = a;

			while (b != m_entities.end())
			{
				pEntity second = *b; b++;

				if (second == nullptr)
					continue;
				
				if (first->DoesCollide(second))
					first->OnCollision(second);
			}
		}

		EntityList::iterator b = m_delQueue.begin();

		while (b != m_delQueue.end())
		{
			pEntity entity = *b; b++;
			m_entities.remove(entity);
		}
		
		m_delQueue.clear();
	}

	void Physics::Clear()
	{
		EntityList::iterator a = m_entities.begin();

		while (a != m_entities.end())
		{
			pEntity entity = *a; a++;
			m_delQueue.push_back(entity);
		}
	}
	
	void Physics::Add(Entity* entity)
	{
		pEntity sharedPtr = pEntity(entity);
		m_entities.push_back(sharedPtr);
	}
		
	Physics::Physics() {}

	Physics::~Physics() {}
}
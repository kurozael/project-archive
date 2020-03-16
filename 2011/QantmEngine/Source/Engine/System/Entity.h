/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef ENTITY_H
#define ENTITY_H

#include <Engine/System/Component.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Math/EAngle.h>
#include <Engine/Math/BBox.h>
#include <memory>
#include <string>
#include <list>

namespace en
{
	class Entity;
		typedef std::shared_ptr<Entity> pEntity;
		typedef std::list<pEntity> EntityList;
	
	class Entity : public Component
	{
	public:
		virtual void OnCollision(pEntity& collider) {};
		virtual bool DoesCollide(pEntity& other)
		{
			return false;
		}
		virtual std::string GetClass();
		void SetAngle(EAngle& angle);
		void SetPos(Vector3f& position);
		EAngle& GetAngle();
		Vector3f& GetPos();
		void Draw();
		void Update();
	public:
		virtual ~Entity();
	protected:
		Vector3f m_position;
		EAngle m_angle;
	};
}

#endif
/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/System/Entity.h>

namespace en
{
	std::string Entity::GetClass()
	{
		return "Entity";
	}

	void Entity::SetAngle(EAngle& angle)
	{
		m_angle = angle;
	}

	void Entity::SetPos(Vector3f& position)
	{
		m_position = position;
	}
	
	EAngle& Entity::GetAngle()
	{
		return m_angle;
	}

	Vector3f& Entity::GetPos()
	{
		return m_position;
	}

	void Entity::Update()
	{
		OnUpdate();
	}

	void Entity::Draw()
	{
		OnDraw();
	}

	Entity::~Entity() {}
}
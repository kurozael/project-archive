/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef SQUAREROOM_H
#define SQUAREROOM_H

#include <Engine/Graphics/Material.h>
#include <Engine/System/Entity.h>

namespace en
{
	class SquareRoom : public Entity
	{
	public:
		void OnDraw();
		void OnUpdate();
		void OnEvent(sf::Event& event);
		void SetWalls(pMaterial& material);
		void SetFloor(pMaterial& material);
		void SetRoof(pMaterial& material);
		void SetSize(float size);
		void SetHeight(float height);
		float GetSize();
		~SquareRoom();
		SquareRoom();
	public:
		pMaterial m_walls;
		pMaterial m_floor;
		pMaterial m_roof;
		float m_height;
		float m_size;
	};

	typedef std::shared_ptr<SquareRoom> pSquareRoom;
}

#endif
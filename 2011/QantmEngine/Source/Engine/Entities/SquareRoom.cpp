/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Graphics/Render.h>
#include <Engine/Entities/SquareRoom.h>
#include <Engine/Math/LineSeg.h>
#include <Engine/System/Asset.h>
#include <Engine/Game.h>

namespace en
{
	void SquareRoom::SetHeight(float height)
	{
		m_height = height;
	}

	void SquareRoom::SetWalls(pMaterial& material)
	{
		m_walls = material;
	}
	
	void SquareRoom::SetFloor(pMaterial& material)
	{
		m_floor = material;
	}
	
	void SquareRoom::SetRoof(pMaterial& material)
	{
		m_roof = material;
	}

	void SquareRoom::SetSize(float size)
	{
		m_size = size;
	}

	float SquareRoom::GetSize()
	{
		return m_size;
	}
	
	void SquareRoom::OnEvent(sf::Event& event) {}

	void SquareRoom::OnUpdate() {}

	void SquareRoom::OnDraw()
	{
		glPushMatrix();
			glTranslatef(m_position.x, m_position.y, m_position.z);
			glScalef(m_size, m_size * m_height, m_size);

			m_walls->Bind();
			glBegin(GL_QUADS);
			glTexCoord2f(0, 1); glVertex3f( -1.0f, -1.0f, -1.0f );
			glTexCoord2f(1, 1); glVertex3f( 1.0f, -1.0f, -1.0f );
			glTexCoord2f(1, 0); glVertex3f(  1.0f, 1.0f, -1.0f );
			glTexCoord2f(0, 0); glVertex3f( -1.0f,  1.0f, -1.0f );
			glEnd();

			glBegin(GL_QUADS);
			glTexCoord2f(0, 1); glVertex3f(  1.0f, -1.0f, -1.0f );
			glTexCoord2f(1, 1); glVertex3f(  1.0f, -1.0f,  1.0f );
			glTexCoord2f(1, 0); glVertex3f(  1.0f,  1.0f,  1.0f );
			glTexCoord2f(0, 0); glVertex3f(  1.0f,  1.0f, -1.0f );
			glEnd();

			glBegin(GL_QUADS);
			glTexCoord2f(0, 1); glVertex3f(  1.0f, -1.0f,  1.0f );
			glTexCoord2f(1, 1); glVertex3f( -1.0f, -1.0f,  1.0f );
			glTexCoord2f(1, 0); glVertex3f( -1.0f,  1.0f, 1.0f );
			glTexCoord2f(0, 0); glVertex3f(  1.0f,  1.0f,  1.0f );
			glEnd();

			glBegin(GL_QUADS);
			glTexCoord2f(0, 1); glVertex3f( -1.0f, -1.0f,  1.0f );
			glTexCoord2f(1, 1); glVertex3f( -1.0f, -1.0f, -1.0f );
			glTexCoord2f(1, 0); glVertex3f( -1.0f,  1.0f, -1.0f );
			glTexCoord2f(0, 0); glVertex3f( -1.0f,  1.0f,  1.0f );
			glEnd();
			m_walls->Unbind();

			m_floor->Bind();
			glBegin(GL_QUADS);
			glTexCoord2f(0, 0); glVertex3f( -1.0f, -1.0f, -1.0f );
			glTexCoord2f(0, 1); glVertex3f( -1.0f, -1.0f,  1.0f );
			glTexCoord2f(1, 1); glVertex3f(  1.0f, -1.0f,  1.0f );
			glTexCoord2f(1, 0); glVertex3f(  1.0f, -1.0f, -1.0f );
			glEnd();
			m_floor->Unbind();

			m_roof->Bind();
			glBegin(GL_QUADS);
			glTexCoord2f(0, 0); glVertex3f( -1.0f,  1.0f,  1.0f );
			glTexCoord2f(0, 1); glVertex3f( -1.0f,  1.0f, -1.0f );
			glTexCoord2f(1, 1); glVertex3f(  1.0f,  1.0f, -1.0f );
			glTexCoord2f(1, 0); glVertex3f(  1.0f,  1.0f,  1.0f );
			glEnd();
			m_roof->Unbind();
		glPopMatrix();

		glPushMatrix();
			float roomSize = m_size;
			float roomHeight = roomSize * m_height;

			LineSeg xAxis(Vector3f(-roomSize, 0.0f, 0.0f), Vector3f(roomSize, 0.0f, 0.0f));
			LineSeg yAxis(Vector3f(0.0f, -roomHeight, 0.0f), Vector3f(0.0f, roomHeight, 0.0f));
			LineSeg zAxis(Vector3f(0.0f, 0.0f, -roomSize), Vector3f(0.0f, 0.0f, roomSize));

			Render::World::LineSeg(xAxis, Color(1.0f, 0.0f, 0.0f), 2);
			Render::World::LineSeg(yAxis, Color(0.0f, 1.0f, 0.0f), 2);
			Render::World::LineSeg(zAxis, Color(0.0f, 0.0f, 1.0f), 2);
		glPopMatrix();
	}

	SquareRoom::SquareRoom()
	{
		m_floor = Asset<Material>::Grab("textures/floor.jpg");
		m_walls = Asset<Material>::Grab("textures/wall.jpg");
		m_roof = Asset<Material>::Grab("textures/roof.jpg");
		m_height = 0.5f;
	}

	SquareRoom::~SquareRoom() {}
}
/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Graphics/Billboard.h>
#include <Engine/Graphics/OpenGL.h>
#include <Engine/System/Asset.h>

namespace en
{
	void Billboard::EnableLighting()
	{
		m_lighting = true;
	}

	void Billboard::DisableLighting()
	{
		m_lighting = false;
	}

	void Billboard::SetTexture(const std::string& fileName)
	{
		m_texture = Asset<Texture>::Grab(fileName);
	}
	
	void Billboard::SetTexture(const pTexture& texture)
	{
		m_texture = texture;
	}
	
	void Billboard::Draw(const Vector3f& position, float scale)
	{
		if (m_texture == nullptr)
			return;
		
		float modelView[16];
		glGetFloatv(GL_MODELVIEW_MATRIX, modelView); 

		Vector3f right(modelView[0], modelView[4], modelView[8]);
		Vector3f up(modelView[1], modelView[5], modelView[9]);
		Vector3f topLeft = position - (right - up) * scale;
		Vector3f topRight = position + (right + up) * scale;
		Vector3f bottomLeft = position - (right + up) * scale;
		Vector3f bottomRight = position + (right - up) * scale;
		
		OpenGL::PushSetting(GL_LIGHTING, m_lighting);
		OpenGL::PushSetting(GL_DEPTH_WRITEMASK, false);

		m_texture->Bind();
		glPushMatrix();
			glBegin(GL_QUADS);
				glTexCoord2f(0, 1);
				glVertex3f(bottomLeft.x, bottomLeft.y, bottomLeft.z);
				glTexCoord2f(1, 1);
				glVertex3f(bottomRight.x, bottomRight.y, bottomRight.z);
				glTexCoord2f(1, 0);
				glVertex3f(topRight.x, topRight.y, topRight.z);
				glTexCoord2f(0, 0);
				glVertex3f(topLeft.x, topLeft.y, topLeft.z);
			glEnd();
		glPopMatrix();
		m_texture->Unbind();

		OpenGL::PopSetting(GL_DEPTH_WRITEMASK);
		OpenGL::PopSetting(GL_LIGHTING);
	}
	
	Billboard::Billboard(const std::string& fileName)
	{
		SetTexture(fileName);
		m_lighting = true;
	}
	
	Billboard::Billboard(const pTexture& texture)
	{
		SetTexture(texture);
		m_lighting = true;
	}
	
	Billboard::Billboard() : m_lighting(true) {}
	
	Billboard::~Billboard() {}
}
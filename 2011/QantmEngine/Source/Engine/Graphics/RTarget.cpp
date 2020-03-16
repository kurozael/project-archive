/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Graphics/RTarget.h>
#include <Engine/Graphics/Render.h>
#include <SFML/Graphics.hpp>

namespace en
{
	pTexture& RTarget::GetTexture()
	{
		return m_texture;
	}

	void RTarget::DrawQuad(float x, float y, int width, int height)
	{
		if (width == -1)
			width = m_width;

		if (height == -1)
			height = m_height;

		Render::Start2D();
		Render::Screen::Texture(
			x, y, width, height, m_texture
			);
		Render::End2D();
	}
	
	void RTarget::Create(int width, int height)
	{
		m_texture->Create(width, height);
		m_height = height;
		m_width = width;

		glGenFramebuffersEXT(1, &m_frameBuffer);
		glGenRenderbuffersEXT(1, &m_depthBuffer);
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, m_frameBuffer);
		glFramebufferTexture2DEXT(
			GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
			GL_TEXTURE_2D, m_texture->GetTextureID(), 0
		);

		glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, m_depthBuffer);
		glRenderbufferStorageEXT(
			GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT24, width, height
		);
		glFramebufferRenderbufferEXT(
			GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT,
			GL_RENDERBUFFER_EXT, m_depthBuffer
		);
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	}

	void RTarget::Clear()
	{
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, m_frameBuffer);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	}
	
	void RTarget::Begin()
	{
		if (!m_capturing)
		{
			glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, m_frameBuffer);
			m_capturing = true;
		}
	}
	
	void RTarget::End()
	{
		if (m_capturing)
		{
			glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
			m_capturing = false;
		}
	}

	RTarget::RTarget()
	{
		m_texture.reset(new Texture);
		m_capturing = false;
		m_height = 0;
		m_width = 0;
	}
	
	RTarget::~RTarget()
	{
		End();
	}
}
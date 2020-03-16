/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Graphics/Texture.h>
#include <SFML/Graphics.hpp>

namespace en
{
	GLuint Texture::GetTextureID()
	{
		return m_textureID;
	}

	void Texture::UnbindAll()
	{
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, NULL);
	}

	bool Texture::IsLoaded()
	{
		return (m_textureID != -1);
	}

	bool Texture::Load(const std::string& fileName)
	{
		sf::Image image;

		if (!image.LoadFromFile(fileName))
			return false;

		glActiveTexture(GL_TEXTURE0);
		glGenTextures(1, &m_textureID);
		glBindTexture(GL_TEXTURE_2D, m_textureID);

		unsigned int width = image.GetWidth();
		unsigned int height = image.GetHeight();
		const sf::Uint8* pixels = image.GetPixelsPtr();
		int format = GL_RGBA;

		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

		glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
		glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
		// glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

		glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format,
			GL_UNSIGNED_BYTE, pixels);

		gluBuild2DMipmaps(GL_TEXTURE_2D, format, width, height, format,
			GL_UNSIGNED_BYTE, pixels);
		
		if (m_name.empty())
			m_name = fileName;

		return true;
	}

	void Texture::Create(int width, int height)
	{
		glActiveTexture(GL_TEXTURE0);

		if (m_textureID != -1)
			glDeleteTextures(1, &m_textureID);

		glGenTextures(1, &m_textureID);
		glBindTexture(GL_TEXTURE_2D, m_textureID);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glGenerateMipmapEXT(GL_TEXTURE_2D);
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA,
			GL_UNSIGNED_BYTE, NULL);
	}

	void Texture::Bind()
	{
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, m_textureID);
	}

	void Texture::Unbind()
	{
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, NULL);
	}

	Texture::Texture()
	{
		m_textureID = -1;
	}
	
	Texture::~Texture()
	{
		glActiveTexture(GL_TEXTURE0);
		glDeleteTextures(1, &m_textureID);
	}
}
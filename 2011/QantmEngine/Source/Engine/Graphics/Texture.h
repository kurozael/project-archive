/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef TEXTURE_H
#define TEXTURE_H

#include <Engine/Graphics/OpenGL.h>
#include <memory>
#include <string>

namespace en
{	
	class Texture
	{
	public:
		static void UnbindAll();
	public:
		GLuint GetTextureID();
		bool IsLoaded();
		void Unbind();
		void Create(int width, int height);
		bool Load(const std::string& fileName);
		void Bind();
		~Texture();
		Texture();
	private:
		std::string m_name;
		GLuint m_textureID;
	};

	typedef std::shared_ptr<Texture> pTexture;
}

#endif
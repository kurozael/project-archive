/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef RTARGET_H
#define RTARGET_H

#include <Engine/Graphics/OpenGL.h>
#include <Engine/Graphics/Texture.h>
#include <memory>
#include <string>

namespace en
{	
	class RTarget
	{
	public:
		pTexture& GetTexture();
		void DrawQuad(float x, float y, int width = -1, int height = -1);
		void Create(int width, int height);
		void Clear();
		void Begin();
		void End();
		~RTarget();
		RTarget();
	private:
		pTexture m_texture;
		GLuint m_frameBuffer;
		GLuint m_depthBuffer;
		bool m_capturing;
		int m_height;
		int m_width;
	};

	typedef std::shared_ptr<RTarget> pRTarget;
}

#endif
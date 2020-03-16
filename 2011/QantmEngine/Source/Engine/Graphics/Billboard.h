/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef BILLBOARD_H
#define BILLBOARD_H

#include <Engine/Graphics/Texture.h>
#include <Engine/Math/Vector3.h>
#include <memory>
#include <string>

namespace en
{
	class Billboard
	{
	public:
		void EnableLighting();
		void DisableLighting();
		void SetTexture(const std::string& fileName);
		void SetTexture(const pTexture& texture);
		void Draw(const Vector3f& position, float scale);
		Billboard(const std::string& fileName);
		Billboard(const pTexture& texture);
		Billboard();
		~Billboard();
	private:
		pTexture m_texture;
		bool m_lighting;
	};
	
	typedef std::shared_ptr<Billboard> pBillboard;
}

#endif
/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef RENDER_H
#define RENDER_H

#include <Engine/Graphics/Material.h>
#include <Engine/Graphics/Texture.h>
#include <Engine/Graphics/Color.h>
#include <Engine/System/Asset.h>
#include <Engine/Math/LineSeg.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Math/Point.h>
#include <SFML/Graphics.hpp>
#include <string>

namespace en
{
	namespace Render
	{
		struct FontRect
		{
			float x;
			float y;
			float w;
			float h;
		};

		namespace World
		{
			void LineSeg(const en::LineSeg& lineSeg, const Color& color, int lineSize = 1);
			void Sphere(float radius, float slices, float stacks);
			void String(Vector3f& position, Color& color, const std::string& text);
		}

		namespace Screen
		{
			void Material(float x, float y, float w, float h, const pMaterial& material);
			void Texture(float x, float y, float w, float h, const pTexture& texture);
			void Quad(float x, float y, float w, float h, const Color& color);
		}

		namespace Font
		{
			FontRect Draw(float x, float y, float size, const std::string& text, const Color& color = Color());
			void Start(const std::string& fontName = "");
			void End();
		}

		sf::RenderWindow& GetWindow();
		Pointf ToScreen(const Vector3f& position);
		pMaterial GetMaterial(const std::string& fileName);
		pTexture GetTexture(const std::string& fileName);
		void Clear(float r, float g, float b, float a = 1.0f);
		int GetWidth();
		int GetHeight();
		void Start2D();
		void End2D();
	};
}

#endif
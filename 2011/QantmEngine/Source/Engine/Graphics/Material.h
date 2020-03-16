/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef MATERIAL_H
#define MATERIAL_H

#include <Engine/Graphics/Texture.h>
#include <Engine/Graphics/OpenGL.h>
#include <Engine/Graphics/Color.h>
#include <memory>
#include <string>

namespace en
{
	enum MatFlags
	{
		TRANSPARENCY = 1,
		SPHERE_MAP = 2
	};

	class Material
	{
	public:
		void SetTexture(const std::string& fileName);
		void SetTexture(pTexture texture);
		void SetAmbient(const Color& ambient);
		void SetDiffuse(const Color& diffuse);
		void SetSpecular(const Color& specular);
		void SetShininess(float shininess);
		pTexture GetTexture() const;
		const Color& GetAmbient() const;
		const Color& GetDiffuse() const;
		const Color& GetSpecular() const;
		float GetShininess() const;
		void SetName(const std::string& name);
		std::string GetName() const;
	public:
		void GiveFlag(int flag);
		void TakeFlag(int flag);
		void SetFlags(int flags);
		bool HasFlag(int flag);
		void Load(const std::string& fileName);
		void Unbind();
		void Bind();
		~Material();
		Material();
	private:
		std::string m_name;
		Color m_ambient;
		Color m_diffuse;
		Color m_specular;
		float m_shininess;
		pTexture m_texture;
		int m_flags;
	};

	typedef std::shared_ptr<Material> pMaterial;
}

#endif
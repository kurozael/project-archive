/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Graphics/Material.h>
#include <Engine/System/Asset.h>
#include <SFML/Graphics.hpp>

namespace en
{
	void Material::SetTexture(const std::string& fileName)
	{
		m_texture = Asset<Texture>::Grab(fileName);
	}

	void Material::SetTexture(pTexture texture)
	{
		m_texture = texture;
	}

	void Material::SetAmbient(const Color& ambient)
	{
		m_ambient = ambient;
	}
	
	void Material::SetDiffuse(const Color& diffuse)
	{
		m_diffuse = diffuse;
	}
	
	void Material::SetSpecular(const Color& specular)
	{
		m_specular = specular;
	}
	
	void Material::SetShininess(float shininess)
	{
		m_shininess = shininess;
	}

	pTexture Material::GetTexture() const
	{
		return m_texture;
	}
	
	const Color& Material::GetAmbient() const
	{
		return m_ambient;
	}
	
	const Color& Material::GetDiffuse() const
	{
		return m_diffuse;
	}
	
	const Color& Material::GetSpecular() const
	{
		return m_specular;
	}
	
	float Material::GetShininess() const
	{
		return m_shininess;
	}

	void Material::SetName(const std::string& name)
	{
		m_name = name;
	}

	std::string Material::GetName() const
	{
		return m_name;
	}

	void Material::GiveFlag(int flag)
	{
		if (!HasFlag(flag))
			m_flags += flag;
	}

	void Material::TakeFlag(int flag)
	{
		if (HasFlag(flag))
			m_flags -= flag;
	}

	void Material::SetFlags(int flags)
	{
		m_flags = flags;
	}

	bool Material::HasFlag(int flag)
	{
		return ((flag & m_flags) == flag);
	}

	void Material::Unbind()
	{
		if (m_texture != nullptr)
			m_texture->Unbind();

		if ( HasFlag(TRANSPARENCY) )
			OpenGL::PopSetting(GL_DEPTH_WRITEMASK);

		if ( HasFlag(SPHERE_MAP) )
		{
			OpenGL::PopSetting(GL_TEXTURE_GEN_S);
			OpenGL::PopSetting(GL_TEXTURE_GEN_T);
		}
	}
	
	void Material::Bind()
	{
		GLfloat ambient[] = {m_ambient.r, m_ambient.g, m_ambient.b, m_ambient.a};
		glMaterialfv(GL_FRONT, GL_AMBIENT, ambient);

		GLfloat diffuse[] = {m_diffuse.r, m_diffuse.g, m_diffuse.b, m_diffuse.a};
		glMaterialfv(GL_FRONT, GL_DIFFUSE, diffuse);

		GLfloat specular[] = {m_specular.r, m_specular.g, m_specular.b, m_specular.a};
		glMaterialfv(GL_FRONT, GL_SPECULAR, specular);

		glMaterialf(GL_FRONT, GL_SHININESS, m_shininess);

		if (m_texture != nullptr)
			m_texture->Bind();

		if ( HasFlag(TRANSPARENCY) )
			OpenGL::PushSetting(GL_DEPTH_WRITEMASK, false);

		if ( HasFlag(SPHERE_MAP) )
		{
			OpenGL::PushSetting(GL_TEXTURE_GEN_S, true);
			OpenGL::PushSetting(GL_TEXTURE_GEN_T, true);
		}
	}

	void Material::Load(const std::string& fileName)
	{
		m_texture = Asset<Texture>::Grab(fileName);
	}

	Material::Material() : m_shininess(0.0f), m_flags(0) {}
	
	Material::~Material() {}
}
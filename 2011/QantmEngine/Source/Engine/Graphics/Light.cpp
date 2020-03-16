/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Graphics/Light.h>

namespace en
{
	void Light::SetLightType(int lightType)
	{
		m_lightType = lightType;
	}

	void Light::SetAmbient(const Color& ambient)
	{
		m_ambient = ambient;
	}

	void Light::SetDiffuse(const Color& diffuse)
	{
		m_diffuse = diffuse;
	}

	void Light::SetSpecular(const Color& specular)
	{
		m_specular = specular;
	}

	void Light::SetShininess(float shininess)
	{
		m_shininess = shininess;
	}

	void Light::SetEnabled(bool enabled)
	{
		if (enabled)
			glEnable(m_lightType);
		else
			glDisable(m_lightType);
	}

	void Light::SetRadius(float radius)
	{
		m_radius = radius;
	}

	void Light::Toggle()
	{
		if (glIsEnabled(m_lightType))
			SetEnabled(true);
		else
			SetEnabled(false);
	}

	Vector3f& Light::GetPos()
	{
		return m_position;
	}

	void Light::SetPos(Vector3f& position)
	{
		m_position = position;
	}
	
	void Light::Update()
	{
		GLfloat position[] = {m_position.x, m_position.y, m_position.z, 1.0f};
		glLightfv(m_lightType, GL_POSITION, position);
		
		GLfloat ambient[] = {m_ambient.r, m_ambient.g, m_ambient.b};
		glLightfv(m_lightType, GL_AMBIENT, ambient);
		
		GLfloat diffuse[] = {m_diffuse.r, m_diffuse.g, m_diffuse.b};
		glLightfv(m_lightType, GL_DIFFUSE, diffuse);
		
		GLfloat specular[] = {m_specular.r, m_specular.g, m_specular.b};
		glLightfv(m_lightType, GL_SPECULAR, specular);

		glLightf(m_lightType, GL_CONSTANT_ATTENUATION, 1.0f);
		glLightf(m_lightType, GL_LINEAR_ATTENUATION, 1.0f / (2.0f * m_radius));
		glLightf(m_lightType, GL_QUADRATIC_ATTENUATION, 1.0f / (2.0f * m_radius * m_radius));

		glLightf(m_lightType, GL_SHININESS, m_shininess);
	}
	
	Light::Light() : m_shininess(100.0f), m_lightType(GL_LIGHT0),
		m_ambient(1.0f, 1.0f, 1.0f), m_radius(10.0f) {}

	Light::~Light() {}
}
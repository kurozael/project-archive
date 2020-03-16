/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef LIGHT_H
#define LIGHT_H

#include <Engine/Graphics/OpenGL.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Graphics/Color.h>
#include <SFML/System.hpp>
#include <memory>

namespace en
{
	class Light
	{
	public:
		void SetAmbient(const Color& ambient);
		void SetDiffuse(const Color& diffuse);
		void SetSpecular(const Color& specular);
		void SetShininess(float shininess);
		void SetLightType(int m_lightType);
		void SetEnabled(bool enabled);
		void SetRadius(float radius);
		void Toggle();
		Vector3f& GetPos();
		void SetPos(Vector3f& position);
		void Update();
		~Light();
		Light();
	private:
		Vector3f m_position;
		Color m_ambient;
		Color m_diffuse;
		Color m_specular;
		float m_shininess;
		float m_radius;
		int m_lightType;
	};

	typedef std::shared_ptr<Light> pLight;
}

#endif
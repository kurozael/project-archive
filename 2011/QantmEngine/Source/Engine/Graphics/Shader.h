/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/


#ifndef SHADER_H
#define SHADER_H

#include <Engine/Graphics/Texture.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Math/EAngle.h>
#include <Engine/Math/QAngle.h>
#include <Engine/Math/Point.h>
#include <string>

namespace en
{
	class Shader
	{
	public:
		static void UnbindAll();
	public:
		void ResetTexture(const std::string& name);
		void SetTexture(const std::string& name, const pTexture& texture);
		void SetTexture(const std::string& name, const std::string& fileName);
		void SetParam(const std::string& name, float value);
		void SetParam(const std::string& name, const Vector3f& value);
		void SetParam(const std::string& name, const EAngle& value);
		void SetParam(const std::string& name, const QAngle& value);
		void SetParam(const std::string& name, const Pointf& value);
		bool Create(const std::string& vertSrc, const std::string& fragSrc);
		bool LoadFile(const std::string& vertFile, const std::string& fragFile);
		bool LoadName(const std::string& name);
		void Unbind();
		void Bind();
		Shader();
		~Shader();
	private:
		unsigned int m_program;
	};
}

#endif

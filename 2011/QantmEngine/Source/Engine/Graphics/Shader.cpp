/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/


#include <Engine/Graphics/Shader.h>
#include <Engine/Graphics/OpenGL.h>
#include <Engine/System/File.h>
#include <Engine/System/Asset.h>
#include <iostream>
#include <cassert>

namespace en
{
	void Shader::ResetTexture(const std::string& name)
	{
		GLint location = glGetUniformLocation(m_program, name.c_str());
		assert(location != -1);

		glActiveTexture(GL_TEXTURE0);
		glUniform1i(location, GL_TEXTURE0);
	}

	void Shader::SetTexture(const std::string& name, const pTexture& texture)
	{
		GLint location = glGetUniformLocation(m_program, name.c_str());
		assert(location != -1);

		glActiveTexture(GL_TEXTURE1);
		glUniform1i(location, GL_TEXTURE1);
		glBindTexture(GL_TEXTURE_2D, texture->GetTextureID());
	}

	void Shader::SetTexture(const std::string& name, const std::string& fileName)
	{
		SetTexture(name, Asset<Texture>::Grab(fileName));
	}

	void Shader::SetParam(const std::string& name, float value)
	{
		GLint location = glGetUniformLocation(m_program, name.c_str());
			assert(location != -1);
		glUniform1f(location, value);
	}

	void Shader::SetParam(const std::string& name, const Vector3f& value)
	{
		GLint location = glGetUniformLocation(m_program, name.c_str());
			assert(location != -1);
		glUniform3f(location, value.x, value.y, value.z);
	}

	void Shader::SetParam(const std::string& name, const EAngle& value)
	{
		GLint location = glGetUniformLocation(m_program, name.c_str());
			assert(location != -1);
		glUniform3f(location, value.p, value.y, value.r);
	}

	void Shader::SetParam(const std::string& name, const QAngle& value)
	{
		GLint location = glGetUniformLocation(m_program, name.c_str());
			assert(location != -1);
		glUniform4f(location, value.x, value.y, value.z, value.w);
	}

	void Shader::SetParam(const std::string& name, const Pointf& value)
	{
		GLint location = glGetUniformLocation(m_program, name.c_str());
			assert(location != -1);
		glUniform2f(location, value.x, value.y);
	}

	void Shader::UnbindAll()
	{
		glUseProgram(0);
	}

	bool Shader::Create(const std::string& vertSrc, const std::string& fragSrc)
	{
		GLuint vertShader = glCreateShader(GL_VERTEX_SHADER);
		GLuint fragShader = glCreateShader(GL_FRAGMENT_SHADER);

		const GLint vlength = vertSrc.size();
		const GLint flength = fragSrc.size();
		const char* vertStr = vertSrc.c_str();
		const char* fragStr = fragSrc.c_str();

		glShaderSource(vertShader, 1, &vertStr, &vlength);
		glShaderSource(fragShader, 1, &fragStr, &flength);

		static const int ERROR_BUF_SIZE = 2000;
		GLcharARB buffer[ERROR_BUF_SIZE];
		GLint compiled = 0;
		GLint linked;

		glCompileShader(vertShader);
		glGetShaderiv(vertShader, GL_COMPILE_STATUS, &compiled);

		if (!compiled)
		{
			glGetShaderInfoLog(vertShader, ERROR_BUF_SIZE, 0, buffer);
				// Report the error here.
			return false;
		}

		glCompileShader(fragShader);
		glGetShaderiv(fragShader, GL_COMPILE_STATUS, &compiled);

		if (!compiled)
		{
			glGetShaderInfoLog(fragShader, ERROR_BUF_SIZE, 0, buffer);
				// Report the error here.
			return false;
		}

		m_program = glCreateProgram();
			glAttachShader(m_program, vertShader);
			glAttachShader(m_program, fragShader);
		glLinkProgram(m_program);

		glGetProgramiv(m_program, GL_OBJECT_LINK_STATUS_ARB, &linked);

		if (!linked)
		{
			glGetProgramInfoLog(m_program, ERROR_BUF_SIZE, 0, buffer);
				// Report the error here.
			return false;
		}

		return true;
	}

	bool Shader::LoadFile(const std::string& vertFile, const std::string& fragFile)
	{
		File vertHandle(vertFile);
		File fragHandle(fragFile);

		assert(vertHandle.IsOpen());
		assert(fragHandle.IsOpen());

		std::string vertSrc;
		std::string fragSrc;

		while (!vertHandle.IsEmpty())
			vertSrc.append(vertHandle.GetLine() + "\n");

		while (!fragHandle.IsEmpty())
			fragSrc.append(fragHandle.GetLine() + "\n");

		return Create(vertSrc, fragSrc);
	}

	bool Shader::LoadName(const std::string& name)
	{
		return LoadFile("shaders/" + name + ".vert", "shaders/" + name + ".frag");
	}

	void Shader::Unbind()
	{
		glUseProgram(0);
	}

	void Shader::Bind()
	{
		glUseProgram(m_program);
	}

	Shader::Shader() : m_program(0) {}

	Shader::~Shader() {}
}
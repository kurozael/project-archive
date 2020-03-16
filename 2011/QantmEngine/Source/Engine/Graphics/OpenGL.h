/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef OPENGL_H
#define OPENGL_H

#pragma comment(lib, "opengl32.lib")
#pragma comment(lib, "glu32.lib")

#include <Engine/Graphics/Color.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Math/EAngle.h>
#include <stdlib.h>
#include <GL/glew.h>
#include <GL/glut.h>
#include <vector>
#include <map>

namespace en
{
	typedef std::vector<GLboolean> BoolList;
	typedef std::map<GLenum, BoolList> SettingsMap;

	namespace OpenGL
	{
		void PushSetting(GLenum setting, bool enabled);
		void PopSetting(GLenum setting);
		void SetAmbience(const Color& color);
		void LookAt(const Vector3f& startPos, const Vector3f& endPos, const Vector3f& upVector);
		void Init(int width, int height);
	};
}

#endif
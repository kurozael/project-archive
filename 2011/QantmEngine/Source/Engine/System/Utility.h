/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef UTILITY_H
#define UTILITY_H

#include <Engine/Graphics/Color.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Math/EAngle.h>
#include <Engine/Math/Point.h>
#include <windows.h>
#include <sstream>
#include <vector>
#include <string>

#ifdef _WIN32
#define _USE_MATH_DEFINES
#endif

#include <math.h>

namespace en
{
	typedef std::vector<Pointf> PointList;
	typedef std::vector<Vector3f> VectorList;
	typedef std::vector<std::string> StringList;

	namespace Math
	{
		float Approach(float value, float target, float increment);
		float Clamp(float value, float minimum, float maximum);
		float Random(float mininum, float maximum);
		std::string ToString(float input);
		Vector3f DegToVec(float degrees);
		float DegToRad(float degrees);
	}

	namespace String
	{
		StringList Split(const std::string& string, char seperator);
		Vector3f ToVec3(const StringList& strings, int sIndex = 0);
		Color ToColor(const StringList& strings, int sIndex = 0);
		Pointf ToPoint(const StringList& strings, int sIndex = 0);
		float ToFloat(const std::string& string);
		int ToInt(const std::string& string);
		void Trim(std::string* string);
	}

	/*
		IsExtensionSupported.
		http://nehe.gamedev.net/tutorial/vertex_buffer_objects/22002/
	*/

	bool IsExtensionSupported(char* szTargetExtension);
	void EngineError(const std::string& text, const std::string& title = "CloudEngine3D");
}

#endif
/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#define _USE_MATH_DEFINES

#include <Engine/System/Utility.h>
#include <Engine/Graphics/OpenGL.h>
#include <algorithm>
#include <map>

namespace en
{
	namespace Math
	{
		float Approach(float value, float target, float increment)
		{
			if (target > value)
				return Clamp(value + increment, value, target);
			else
				return Clamp(value - increment, target, value);
		}

		float Clamp(float value, float minimum, float maximum)
		{
			if (value > maximum)
				return maximum;
			else if (value < minimum)
				return minimum;
			else
				return value;
		}
		
		float Random(float minimum, float maximum)
		{
			return ((float(rand()) / float(RAND_MAX)) * (maximum - minimum)) + minimum;
		}

		std::string ToString(float input)
		{
			std::stringstream stream;
			std::string result;
			stream << input;
			stream >> result;
			return result;
		}

		Vector3f DegToVec(float degrees)
		{
			return Vector3f(
				std::sin(DegToRad(degrees)), 0.0f, std::cos(DegToRad(degrees))
			);
		}

		float DegToRad(float degrees)
		{
			return degrees * ((float)M_PI / 180.0f);
		}
	}

	namespace String
	{
		StringList Split(const std::string& string, char seperator)
		{
			StringList results;
			std::string strCopy(string);

			while (true) 
			{
				int i = strCopy.find(seperator);
				if (i == std::string::npos)
				{
					results.push_back(strCopy);
					break; 
				}    
				else
				{
					results.push_back(strCopy.substr(0, i));
					strCopy = strCopy.substr(i + 1);
					Trim(&strCopy);
					if (strCopy.empty())
						break;
				}
			}

			return results;
		}

		Vector3f ToVec3(const StringList& strings, int sIndex)
		{
			return Vector3f(ToFloat(strings[sIndex]), ToFloat(strings[sIndex + 1]), ToFloat(strings[sIndex + 2]));
		}

		Color ToColor(const StringList& strings, int sIndex)
		{
			return Color(
				ToFloat(strings[sIndex]),
				ToFloat(strings[sIndex + 1]),
				ToFloat(strings[sIndex + 2])
				);
		}

		Pointf ToPoint(const StringList& strings, int sIndex)
		{
			return Pointf(ToFloat(strings[sIndex]), ToFloat(strings[sIndex + 1]));
		}
		
		float ToFloat(const std::string& string)
		{
			return (float)atof(string.c_str());
		}

		int ToInt(const std::string& string)
		{
			return atoi(string.c_str());
		}
		
		void Trim(std::string* string)
		{
			while (!string->empty() && (string->at(0) == ' ' || string->at(0) == '\r'
				|| string->at(0) == '\n' ) )
			{
				*string = string->substr(1);
			}
			while (!string->empty() && (string->at(string->size() - 1) == ' '
				|| string->at(string->size() - 1) == '\r' || string->at(string->size() - 1) == '\n') )
			{
				*string = string->substr(0, string->size() - 1);
			}
		}
	}

	bool IsExtensionSupported(char* szTargetExtension)
	{
		const unsigned char *pszExtensions = NULL;
		const unsigned char *pszStart;
		unsigned char *pszWhere, *pszTerminator;

		pszWhere = (unsigned char*) strchr(szTargetExtension, ' ');
		if (pszWhere || *szTargetExtension == '\0')
			return false;

		pszExtensions = glGetString(GL_EXTENSIONS);
		pszStart = pszExtensions;

		for(;;)
		{
			pszWhere = (unsigned char*) strstr((const char*) pszStart, szTargetExtension);
			if(!pszWhere) break;

			pszTerminator = pszWhere + strlen(szTargetExtension);
			if(pszWhere == pszStart || * (pszWhere - 1) == ' ')
				if (*pszTerminator == ' ' || *pszTerminator == '\0')
					return true;

			pszStart = pszTerminator;
		}

		return false;
	}

	void EngineError(const std::string& text, const std::string& title)
	{
		MessageBoxA(NULL, text.c_str(), title.c_str(), MB_ICONERROR | MB_OK); 
	}
}
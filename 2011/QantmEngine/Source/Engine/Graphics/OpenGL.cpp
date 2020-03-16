/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Graphics/OpenGL.h>
#include <Engine/Game.h>

namespace en
{
	namespace OpenGL
	{
		SettingsMap g_Settings = SettingsMap();

		void PushSetting(GLenum setting, bool enabled)
		{
			if (setting == GL_DEPTH_WRITEMASK)
			{
				GLboolean depthMask = true;
				glGetBooleanv(GL_DEPTH_WRITEMASK, &depthMask);

				g_Settings[setting].push_back(depthMask);

				if (enabled)
					glDepthMask(GL_TRUE);
				else
					glDepthMask(GL_FALSE);
			}
			else
			{
				g_Settings[setting].push_back(
					glIsEnabled(setting)
				);

				if (enabled)
					glEnable(setting);
				else
					glDisable(setting);
			}
		}

		void PopSetting(GLenum setting)
		{
			BoolList& settingStack = g_Settings[setting];

			if (settingStack.size() == 0)
				return;

			if (setting == GL_DEPTH_WRITEMASK)
			{
				if (settingStack.back())
					glDepthMask(GL_TRUE);
				else
					glDepthMask(GL_FALSE);
			}
			else
			{
				if (settingStack.back())
					glEnable(setting);
				else
					glDisable(setting);
			}

			settingStack.pop_back();
		}

		void SetAmbience(const Color& color)
		{
			GLfloat ambient[] = {color.r, color.g, color.b, 1.0};
			glLightModelfv(GL_LIGHT_MODEL_AMBIENT, ambient);
		}

		void LookAt(const Vector3f& startPos, const Vector3f& endPos, const Vector3f& upVector)
		{
			gluLookAt(
				startPos.x, startPos.y, startPos.z,
				endPos.x, endPos.y, endPos.z,
				upVector.x, upVector.y, upVector.z
			);
		}

		void Init(int width, int height)
		{
			glEnable(GL_LIGHTING);
			glEnable(GL_TEXTURE_2D);
			glEnable(GL_DEPTH_TEST);
			glEnable(GL_COLOR_MATERIAL);
			glEnable(GL_BLEND);
			glEnable(GL_POLYGON_SMOOTH);
			glEnable(GL_CULL_FACE);
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			glDepthMask(GL_TRUE);
			glCullFace(GL_BACK);

			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			gluPerspective(45.0f, width / height, 1.0f, 1000.0f);

			glewInit();
		}
	}
}
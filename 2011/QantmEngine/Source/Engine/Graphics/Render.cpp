/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Graphics/OpenGL.h>
#include <Engine/Graphics/Render.h>
#include <Engine/Game.h>

namespace en
{
	namespace Render
	{
		namespace World
		{
			void Sphere(float radius, float slices, float stacks)
			{
				GLUquadric* quad = gluNewQuadric();
					gluQuadricTexture(quad, true);
				gluSphere(quad, radius, slices, stacks);
			}

			void LineSeg(const en::LineSeg& lineSeg, const Color& color, int lineSize)
			{
				OpenGL::PushSetting(GL_TEXTURE_2D, false);
				OpenGL::PushSetting(GL_LIGHTING, false);

				glLineWidth(lineSize);

				Vector3f start = lineSeg.GetStart();
				Vector3f end = lineSeg.GetEnd();

				glBegin(GL_LINES);
					glColor3f(color.r, color.g, color.b);
					glVertex3f(start.x, start.y, start.z);
					glColor3f(color.r, color.g, color.b);
					glVertex3f(end.x, end.y, end.z);
					glColor3f(1, 1, 1);
				glEnd();

				OpenGL::PopSetting(GL_TEXTURE_2D);
				OpenGL::PopSetting(GL_LIGHTING);
			}

			void String(Vector3f& position, Color& color, const std::string& text)
			{
				OpenGL::PushSetting(GL_LIGHTING, false);
					glColor3f(color.r, color.g, color.b);
					glRasterPos3f(position.x, position.y, position.z);

					for (unsigned int i = 0; i < text.length(); i++)
					{
						glutBitmapCharacter(
							GLUT_BITMAP_HELVETICA_12, text[i]
						);
					}

					glColor3f(1, 1, 1);
				OpenGL::PopSetting(GL_LIGHTING);
			}
		}

		namespace Screen
		{
			void Material(float x, float y, float w, float h, const pMaterial& material)
			{
				glPushMatrix();
					glTranslatef(x, y, 0.0f);
					material->Bind();
					glBegin(GL_QUADS);
						glTexCoord2f(1.0f, 0.0f);
						glVertex2f(w, 0.0f);
						glTexCoord2f(0.0f, 0.0f);
						glVertex2f(0.0f, 0.0f);
						glTexCoord2f(0.0f, 1.0f);
						glVertex2f(0.0f, h);
						glTexCoord2f(1.0f, 1.0f);
						glVertex2f(w, h);
					glEnd();
					material->Unbind();
				glPopMatrix();
			}

			void Texture(float x, float y, float w, float h, const pTexture& texture)
			{
				glPushMatrix();
					glTranslatef(x, y, 0.0f);
					texture->Bind();
					glBegin(GL_QUADS);
						glTexCoord2f(1.0f, 0.0f);
						glVertex2f(w, 0.0f);
						glTexCoord2f(0.0f, 0.0f);
						glVertex2f(0.0f, 0.0f);
						glTexCoord2f(0.0f, 1.0f);
						glVertex2f(0.0f, h);
						glTexCoord2f(1.0f, 1.0f);
						glVertex2f(w, h);
					glEnd();
					texture->Unbind();
				glPopMatrix();
			}

			void Quad(float x, float y, float w, float h, const Color& color)
			{
				glPushMatrix();
					glTranslatef(x, y, 0.0f);
					glColor4f(color.r, color.g, color.b, color.a);
					glBegin(GL_QUADS);
						glTexCoord2f(1.0f, 0.0f);
						glVertex2f(w, 0.0f);
						glTexCoord2f(0.0f, 0.0f);
						glVertex2f(0.0f, 0.0f);
						glTexCoord2f(0.0f, 1.0f);
						glVertex2f(0.0f, h);
						glTexCoord2f(1.0f, 1.0f);
						glVertex2f(w, h);
					glEnd();
					glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
				glPopMatrix();
			}
		}

		namespace Font
		{
			sf::Font g_CurrentFont;

			FontRect Draw(float x, float y, float size, const std::string& text, const Color& color)
			{
				sf::Font textFont = sf::Font::GetDefaultFont();
				sf::Text textObj(sf::String(text), g_CurrentFont);

				textObj.SetPosition(x, y);
				textObj.SetColor(sf::Color(color.r * 255, color.g * 255, color.b * 255));
				textObj.SetCharacterSize(size);
				GetWindow().Draw(textObj);

				FontRect fontRect;
					fontRect.x = x;
					fontRect.y = y;
					fontRect.w = textObj.GetRect().Width;
					fontRect.h = textObj.GetRect().Height;
				return fontRect;
			}

			void Start(const std::string& fontName)
			{
				GetWindow().SaveGLStates();

				if (fontName != "")
					g_CurrentFont.LoadFromFile("fonts/" + fontName + ".ttf");
				else
					g_CurrentFont = g_CurrentFont.GetDefaultFont();
			}

			void End()
			{
				GetWindow().RestoreGLStates();
			}
		}

		Pointf ToScreen(const Vector3f& position)
		{
			GLint viewport[4];
			GLdouble modelView[16];
			GLdouble projection[16];
			GLdouble winx, winy, winz;

			glGetIntegerv(GL_VIEWPORT, viewport);
			glGetDoublev(GL_MODELVIEW_MATRIX, modelView);
			glGetDoublev(GL_PROJECTION_MATRIX, projection);

			/* The old one was -y, -x, z. */
			gluProject(
				position.x, position.y, position.z, modelView,
				projection, viewport, &winx, &winy, &winz
				);

			return Pointf(winx, GetHeight() - winy);
		}

		pMaterial GetMaterial(const std::string& fileName)
		{
			return Asset<Material>::Grab(fileName);
		}

		pTexture GetTexture(const std::string& fileName)
		{
			return Asset<Texture>::Grab(fileName);
		}

		sf::RenderWindow& GetWindow()
		{
			return Singleton<Game>::Get()->GetWindow();
		}

		void Clear(float r, float g, float b, float a)
		{
			glClearColor(r, g, b, a);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		}

		int GetWidth()
		{
			return GetWindow().GetWidth();
		}

		int GetHeight()
		{
			return GetWindow().GetHeight();
		}

		GLfloat g_Projection[16];
		GLfloat g_ModelView[16];

		void Start2D()
		{
			glGetFloatv(GL_PROJECTION_MATRIX, g_Projection);
			glGetFloatv(GL_MODELVIEW_MATRIX, g_ModelView);

			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			gluOrtho2D(0.0f, GetWidth(), GetHeight(), 0.0f);

			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();

			/* Save our settings for later... */
			OpenGL::PushSetting(GL_LIGHTING, false);
			OpenGL::PushSetting(GL_DEPTH_TEST, false);
			OpenGL::PushSetting(GL_CULL_FACE, false);
			OpenGL::PushSetting(GL_DEPTH_WRITEMASK, false);
		}

		void End2D()
		{
			glMatrixMode(GL_PROJECTION);
			glLoadMatrixf(g_Projection);

			glMatrixMode(GL_MODELVIEW);
			glLoadMatrixf(g_ModelView);

			/* Restore our default settings... */
			OpenGL::PopSetting(GL_DEPTH_WRITEMASK);
			OpenGL::PopSetting(GL_LIGHTING);
			OpenGL::PopSetting(GL_DEPTH_TEST);
			OpenGL::PopSetting(GL_CULL_FACE);
			glDepthMask(GL_TRUE);
		}
	}
}
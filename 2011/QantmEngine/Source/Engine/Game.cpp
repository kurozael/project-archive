/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/States/PlayingState.h>
#include <Engine/Graphics/Render.h>
#include <Engine/System/Utility.h>
#include <Engine/System/Events.h>
#include <Engine/System/Timer.h>
#include <Engine/Settings.h>
#include <Engine/Game.h>

namespace en
{
	sf::RenderWindow& Game::GetWindow()
	{
		return m_window;
	}

	State* Game::GetActiveState()
	{
		return m_activeState;
	}

	State* Game::GetNextState()
	{
		return m_nextState;
	}

	void Game::SetState(State* state)
	{
		if (m_nextState == NULL)
			m_nextState = state;
	}

	void Game::PollEvents(sf::Event& event)
	{
		while ( m_window.PollEvent(event) )
		{
			if (event.Type == sf::Event::Closed)
				m_window.Close();

			Singleton<Events>::Get()->Handle(event);
		}
	}

	void Game::Update()
	{
		m_activeState->OnUpdate();
	}
	
	void Game::Init()
	{
		m_window.Create(
			sf::VideoMode(1600, 900, 32), "CloudEngine3D",
			sf::Style::Titlebar | sf::Style::Close, sf::ContextSettings(32)
		);

		m_window.EnableVerticalSync(true);
		m_window.SetFramerateLimit(60.0f);
		OpenGL::Init(1600, 900);

		sf::Image icon;
		if (icon.LoadFromFile("icon.png"))
			m_window.SetIcon(32, 32, icon.GetPixelsPtr());

		if (!IsExtensionSupported("GL_EXT_framebuffer_object"))
		{
			EngineError("The OpenGL Frame Buffer Object extension is not supported!");
			exit(0);
		}

		m_activeState = Singleton<PlayingState>::Get();
		m_activeState->OnLoad();
	}

	void Game::Loop()
	{
		while (m_window.IsOpened())
		{
			sf::Event event;
			PollEvents(event);
			
			m_window.Clear();
				Update(); Draw();
			m_window.Display();

			if (m_nextState != NULL)
			{
				m_activeState->OnUnload();
				m_activeState = m_nextState;
				m_activeState->OnLoad();
				m_nextState = NULL;
			}
		}
	}

	void Game::Draw()
	{		
		Render::Clear(0, 0, 0);

		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();

		unsigned int width = m_window.GetWidth();
		if (width == 0)
			width = 1;

		unsigned int height = m_window.GetHeight();
		if (height == 0)
			height = 1;

		gluPerspective(45.0f, float(width) / float(height), 1.0f, 1000.0f);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();

		m_activeState->OnDraw();

		Render::Start2D();
			m_activeState->OnPaint();
		Render::End2D();
	}

	Game::Game() : m_activeState(NULL), m_nextState(NULL) {}

	Game::~Game() {}
}
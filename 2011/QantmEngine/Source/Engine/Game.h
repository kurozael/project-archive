/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef GAME_H
#define GAME_H

#include <Engine/System/Singleton.h>
#include <Engine/System/State.h>
#include <SFML/Graphics.hpp>

namespace en
{
	class Game : public sf::NonCopyable
	{
	public:
		sf::RenderWindow& GetWindow();
		State* GetActiveState();
		State* GetNextState();
		void SetState(State* state);
		void Init();
		void Loop();
		~Game();
		Game();
	private:
		void PollEvents(sf::Event& event);
		void Update();
		void Draw();
	private:
		sf::RenderWindow m_window;
		State* m_activeState;
		State* m_nextState;
	};
}

#endif
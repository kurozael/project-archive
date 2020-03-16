/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef TIMER_H
#define TIMER_H

#include <Engine/Game.h>

namespace en
{
	namespace Timer
	{
		static sf::Clock Clock;
		float CurTime();
		float GetFPS();
		float GetDT();
	}
}

#endif
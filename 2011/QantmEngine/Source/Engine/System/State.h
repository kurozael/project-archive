/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef STATE_H
#define STATE_H

#include <Engine/System/Component.h>
#include <Engine/System/Singleton.h>
#include <Engine/Settings.h>

namespace en
{
	class State : public Component
	{
	public:
		virtual void OnLoad() {};
		virtual void OnUnload() {};
		virtual ~State() {};
	};

	typedef std::shared_ptr<State> pGameState;
}

#endif
/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef MOVECAM_H
#define MOVECAM_H

#include <Engine/System/Entity.h>

namespace en
{
	class MoveCam : public Entity
	{
	public:
		void OnDraw();
		void OnUpdate();
		void OnEvent(sf::Event& event);
		void SetLookAt();
		~MoveCam();
		MoveCam();
	};

	typedef std::shared_ptr<MoveCam> pMoveCam;
}

#endif
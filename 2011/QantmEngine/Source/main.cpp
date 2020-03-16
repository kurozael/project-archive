/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Game.h>

int main(int argc, char** argv)
{
	en::Game* game = en::Singleton<en::Game>::Get();
		game->Init();
		game->Loop();
	return EXIT_SUCCESS;
}
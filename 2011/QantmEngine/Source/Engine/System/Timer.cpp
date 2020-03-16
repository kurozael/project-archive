/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/System/Timer.h>

namespace en
{
	namespace Timer
	{
		float GetFPS()
		{
			return (1.0f / GetDT());
		}

		float GetDT()
		{
			return float(Singleton<Game>::Get()->GetWindow().GetFrameTime()) / 1000.0f;
		}

		float CurTime()
		{
			return float(Clock.GetElapsedTime() / 1000.0f);
		}
	}
}
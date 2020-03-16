/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Graphics/Color.h>

namespace en
{
	void Color::SetAlpha(float na)
	{
		a = na;
	}

	void Color::Normalize()
	{
		r /= 255;
		g /= 255;
		b /= 255;
		a /= 255;
	}

	void Color::ToWhite()
	{
		r = 1;
		g = 1;
		b = 1;
	}

	void Color::ToBlack()
	{
		r = 0;
		g = 0;
		b = 0;
	}

	Color::Color(float nr, float ng, float nb, float na)
	{
		r = nr; g = ng;
		b = nb; a = na;
	}
	
	Color::Color() : r(1), g(1), b(1), a(1) {}
	
	Color::~Color() {}
}
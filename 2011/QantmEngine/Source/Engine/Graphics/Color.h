/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef COLOR_H
#define COLOR_H

namespace en
{
	class Color
	{
	public:
		void SetAlpha(float na);
		void Normalize();
		void ToWhite();
		void ToBlack();
		Color(float nr, float ng, float nb, float na = 1);
		Color();
		~Color();
	public:
		float r;
		float g;
		float b;
		float a;
	};

	namespace Constants
	{
		static Color WHITE = Color();
		static Color BLACK = Color(0, 0, 0, 1);
	}
}

#endif
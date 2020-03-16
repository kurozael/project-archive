/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef POINT_H
#define POINT_H

namespace en
{
	template <typename T>
	class Point
	{
	public:
		Point(T px, T py) : x(px), y(py) {};
		Point() : x(0), y(0) {};
		~Point() {};
	public:
		T x;
		T y;
	};

	typedef Point<double> Pointd;
	typedef Point<float> Pointf;
	typedef Point<int> Pointi;
}

#endif
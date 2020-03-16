/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef VECTOR3_H
#define VECTOR3_H

#include <algorithm>
#include <math.h>

namespace en
{
	template <typename T>
	class Vector3
	{
	public:
		Vector3<T> operator+(const Vector3<T>& rhs) const
		{
			return Vector3<T>(x + rhs.x, y + rhs.y, z + rhs.z);
		};
		Vector3<T> operator-(const Vector3<T>& rhs) const

		{
			return Vector3<T>(x - rhs.x, y - rhs.y, z - rhs.z);
		};
		Vector3<T> operator*(const Vector3<T>& rhs) const
		{
			return Vector3<T>(x * rhs.x, y * rhs.y, z * rhs.z);
		};
		Vector3<T> operator*(const T& rhs) const
		{
			return Vector3<T>(x * rhs, y * rhs, z * rhs);
		};
		Vector3<T> operator-() const
		{
			return Vector3<T>(-x, -y, -z);
		};
		Vector3<T> operator/(const Vector3<T>& rhs) const
		{
			return Vector3<T>(x / rhs.x, y / rhs.y, z / rhs.z);
		};
		Vector3<T> operator/(const T& rhs) const
		{
			return Vector3<T>(x / rhs, y / rhs, z / rhs);
		};
		Vector3<T>& operator+=(const T& rhs)
		{
			x += rhs;
			y += rhs;
			z += rhs;
			return *this;
		};
		Vector3<T>& operator-=(const T& rhs)
		{
			x -= rhs;
			y -= rhs;
			z -= rhs;
			return *this;
		};
		Vector3<T>& operator*=(const T& rhs)
		{
			x *= rhs;
			y *= rhs;
			z *= rhs;
			return *this;
		};
		Vector3<T>& operator/=(const T& rhs)
		{
			x /= rhs;
			y /= rhs;
			z /= rhs;
			return *this;
		};
		T Dot(const Vector3<T>& rhs)
		{
			return (x * rhs.x) + (y * rhs.y) + (z * rhs.z);
		};
		Vector3<T> Cross(const Vector3<T>& rhs)
		{
			return Vector3<T>(
				(y * rhs.z) - (z * rhs.y),
				(z * rhs.x) - (x * rhs.z),
				(x * rhs.y) - (y * rhs.x)
			);
		};
		T Length()
		{
			return sqrt( SquaredLength() );
		};
		T Distance(const Vector3<T>& other) const
		{
			T xd = other.x - x;
			T yd = other.y - y;
			T zd = other.z - z;
			return sqrt((xd * xd) + (yd * yd) + (zd * zd));
		};
		T SquaredLength()
		{
			return (x * x) + (y * y) + (z * z);
		};
		Vector3<T>& Normalize()
		{
			*this *= ( 1.0f / Length() );
			return *this;
		};
		Vector3<T> NormalCopy() const
		{
			return Vector3<T>(x, y, z).Normalize();
		};
		Vector3(T px, T py, T pz) : x(px), y(py), z(pz) {};
		Vector3() : x(0), y(0), z(0) {};
		~Vector3() {};
	public:
		T x;
		T y;
		T z;
	};

	typedef Vector3<double> Vector3d;
	typedef Vector3<float> Vector3f;
	typedef Vector3<int> Vector3i;

	namespace Constants
	{
		static Vector3f ORIGIN = Vector3f();
		static Vector3f AXIS_X = Vector3f(1.0f, 0.0f, 0.0f);
		static Vector3f AXIS_Y = Vector3f(0.0f, 1.0f, 0.0f);
		static Vector3f AXIS_Z = Vector3f(0.0f, 0.0f, 1.0f);
	}
}

#endif
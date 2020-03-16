/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef OCTREE_H
#define OCTREE_H

#include <Engine/Graphics/Triangle.h>
#include <Engine/Math/BBox.h>
#include <vector>

namespace en
{
	namespace Octree
	{
		class Generic
		{
		public:
			virtual ~Generic() {};
			virtual void Draw() = 0;
		protected:
			BBox m_bbox;
		};
		
		class Leaf : public Generic
		{
		public:
			virtual void Draw();
			Leaf(const TriangleList& triangles, const BBox& bbox);
		private:
			TriangleList m_triangles;
		};

		class Composite : public Generic
		{
		public:
			virtual void Draw();
			void Add(Generic*);
			Composite(const BBox& bbox);
		private:
			std::vector<Generic*> m_children;
		};

		Generic* Create(const TriangleList& triangles, const BBox& bbox, int recursionDepth);
	}
}

#endif
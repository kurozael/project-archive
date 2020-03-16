/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Math/Octree.h>
#include <Engine/Graphics/Color.h>
#include <Engine/Settings.h>

namespace en
{
	namespace Octree
	{
		static const int TOO_MANY = 1;
		static const int MAX_RECURSION_DEPTH = 5;

		void Composite::Draw()
		{
			m_bbox.Draw(Color(0.5f, 0.5f, 0.5f), 1);
			
			for (unsigned int i = 0; i < m_children.size(); i++)
			{
				m_children[i]->Draw();
			}
		}

		void Composite::Add(Generic* child)
		{
			m_children.push_back(child);
		}
		
		Composite::Composite(const BBox& bbox)
		{
			m_bbox = bbox;
		}
		
		void Leaf::Draw() 
		{
			m_bbox.Draw(Color(1, 1, 1), 1);
			
			if (DEBUG_OCTREE)
			{
				glBegin(GL_TRIANGLES);
					for (unsigned int i = 0; i < m_triangles.size(); i++)
					{
						m_triangles[i].Draw();
					}
				glEnd();
			}
		}
		
		Leaf::Leaf(const TriangleList& triangles, const BBox& bbox)
		{
			m_triangles = triangles;
			m_bbox = bbox;
		}

		Generic* Create(const TriangleList& triangles, const BBox& bbox, int recursionDepth)
		{
			if (recursionDepth >= MAX_RECURSION_DEPTH)
			{
				return new Leaf(triangles, bbox);        
			}

			if (triangles.size() < TOO_MANY)
			{
				return new Leaf(triangles, bbox);        
			}

			Composite* pComp = new Composite(bbox);
			
			for (int i = 0; i < 8; i++)
			{
				BBox childBox = bbox.GetOctChild(i);
				TriangleList trisInChildBox;

				for (unsigned int j = 0; j < triangles.size(); j++)
				{
					const Triangle& triangle = triangles[j];
					Vector3f vector;

					for (int k = 0; k < 3; k++)
						vector = vector + triangle.verts[k].point;

					vector *= (1.0 / 3.0);

					if (childBox.Contains(vector))
						trisInChildBox.push_back(triangle);
				}

				if (!trisInChildBox.empty())
				{
					Generic* pChild = Create(trisInChildBox, childBox, recursionDepth + 1);
					pComp->Add(pChild);
				}
			}

			return pComp;
		}
	}
}
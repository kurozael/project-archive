/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Graphics/StaticMesh.h>
#include <Engine/Graphics/OpenGL.h>
#include <Engine/System/Asset.h>
#include <Engine/System/File.h>
#include <cassert>

namespace en
{
	namespace String
	{
		void ToMeshFace(const StringList& strings, MeshFaces& faces, int sIndex)
		{
			MeshFace newFaceObject;

			for (int i = 0; i < 3; i++)
			{
				StringList splitStrings = Split(strings[i + sIndex], '/');

				if (splitStrings.size() > 0 && !splitStrings[0].empty())
				{
					newFaceObject.idxPoint[i] = ToInt(splitStrings[0]) - 1;
				}

				if (splitStrings.size() > 1 && !splitStrings[1].empty())
				{
					newFaceObject.idxUV[i] = ToInt(splitStrings[1]) - 1;
				}

				if (splitStrings.size() > 2 && !splitStrings[2].empty())
				{
					newFaceObject.idxNormal[i] = ToInt(splitStrings[2]) - 1;
				}
			}

			faces.push_back(newFaceObject);

			/*
				This code is for supporting quads... but allow it...

				if (strings.size() + sIndex > 5)
				{
					StringList newList;
						newList.push_back(strings[sIndex]);
						newList.push_back(strings[sIndex + 2]);
						newList.push_back(strings[sIndex + 3]);
					ToMeshFace(newList, faces, 0);
				}
			*/
		}
	}

	MeshMaterials& StaticMesh::GetMaterials()
	{
		return m_materials;
	}

	VectorList& StaticMesh::GetNormals()
	{
		return m_normals;
	}

	MeshGroups& StaticMesh::GetGroups()
	{
		return m_groups;
	}

	VectorList& StaticMesh::GetPoints()
	{
		return m_points;
	}

	PointList& StaticMesh::GetUVs()
	{
		return m_uvs;
	}

	void StaticMesh::Import(const std::string& fileName)
	{
		File file(fileName); assert(file.IsOpen());
		Material* materialObject = 0;

		while (!file.IsEmpty())
		{
			std::string line = file.GetLine();

			if (line.empty() || line[0] == '#')
				continue;

			StringList strings = String::Split(line, ' ');

			if (strings[0] == "newmtl")
			{
				if (materialObject != NULL)
				{
					std::string name = materialObject->GetName();
						m_materials[name] = *materialObject;
					delete materialObject;

					materialObject = NULL;
				}

				materialObject = new Material();
				materialObject->SetName(strings[1]);
			}
			else if (strings[0] == "Ka")
			{
				materialObject->SetAmbient(
					String::ToColor(strings, 1)
				);
			}
			else if (strings[0] == "Kd")
			{
				materialObject->SetDiffuse(
					String::ToColor(strings, 1)
				);
			}
			else if (strings[0] == "Ks")
			{
				materialObject->SetSpecular(
					String::ToColor(strings, 1)
				);
			}
			else if (strings[0] == "Ns")
			{
				materialObject->SetShininess(
					String::ToFloat(strings[1])
				);
			}
			else if (strings[0] == "map_Kd")
			{
				materialObject->SetTexture(
					strings[1]
				);
			}
		}

		if (materialObject != NULL)
		{
			std::string name = materialObject->GetName();
				m_materials[name] = *materialObject;
			delete materialObject;
		}
	}

	void StaticMesh::Load(const std::string& fileName)
	{
		File file(fileName); assert(file.IsOpen());

		m_groups["default"] = MeshGroup(this);
		MeshGroup* group = &m_groups["default"];

		while (!file.IsEmpty())
		{
			std::string line = file.GetLine();

			if (!line.empty() && line[0] != '#')
			{
				StringList strings = String::Split(line, ' ');

				if (strings[0] == "v")
				{
					Vector3f v = String::ToVec3(strings, 1);
					m_points.push_back(v);
				}
				else if (strings[0] == "f")
				{
					String::ToMeshFace(strings, group->faces, 1);
				}
				else if (strings[0] == "g")
				{
					MeshGroup g(this);
						g.name = strings[1];
						m_groups[g.name] = g;
					group = &m_groups[g.name];
				}
				else if (strings[0] == "vt")
				{
					Pointf vt = String::ToPoint(strings, 1);
					m_uvs.push_back(vt);
				}
				else if (strings[0] == "vn")
				{
					Vector3f vn = String::ToVec3(strings, 1);
					m_normals.push_back(vn);
				}
				else if (strings[0] == "usemtl")
				{
					group->material = strings[1];
				}
				else if (strings[0] == "mtllib")
				{
					Import(strings[1]);
				}
			}
		}
	}
	
	void StaticMesh::SetMaterial(const Material& material, const std::string& group)
	{
		m_materials[group] = material;
	}

	void StaticMesh::Draw()
	{
		MeshGroups::iterator it;

		for (it = m_groups.begin(); it != m_groups.end(); it++)
		{
			it->second.Draw();
		}
	}
	
	StaticMesh::StaticMesh() {}

	StaticMesh::~StaticMesh() {}

	void MeshGroup::Draw()
	{
		assert(mesh != NULL);

		MeshMaterials materials = mesh->GetMaterials();
		Material& groupMat = materials[material];
		VectorList normals = mesh->GetNormals();
		VectorList points = mesh->GetPoints();
		PointList uvs = mesh->GetUVs();

		groupMat.Bind();

		glBegin(GL_TRIANGLES);
			for (unsigned int i = 0; i < faces.size(); i++)
			{
				MeshFace& face = faces[i];

				for (unsigned int j = 0; j < 3; j++)
				{
					int idxNormal = face.idxNormal[j];
					Vector3f& normal = normals[idxNormal];

					int idxPoint = face.idxPoint[j];
					Vector3f& point = points[idxPoint];

					int idxUV = face.idxUV[j];
					Pointf& uv = uvs[idxUV];

					glNormal3f(normal.x, normal.y, normal.z);
					glTexCoord2f(uv.x, uv.y);
					glVertex3f(point.x, point.y, point.z);
				}
			}
		glEnd();

		groupMat.Unbind();
	}
}
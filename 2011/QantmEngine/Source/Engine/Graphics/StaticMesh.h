/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef STATICMESH_H
#define STATICMESH_H

#include <Engine/Graphics/Material.h>
#include <Engine/System/Utility.h>
#include <map>

namespace en
{
	class StaticMesh;

	struct MeshFace
	{
		int idxNormal[3];
		int idxPoint[3];
		int idxUV[3];
	};

	typedef std::vector<MeshFace> MeshFaces;

	struct MeshGroup
	{
	public:
		MeshGroup(StaticMesh* staticMesh) : mesh(staticMesh) {};
		MeshGroup() : mesh(NULL) {};
		void Draw();
	public:
		std::string material;
		std::string name;
		StaticMesh* mesh;
		MeshFaces faces;
	};

	typedef std::map<std::string, MeshGroup> MeshGroups;
	typedef std::map<std::string, Material> MeshMaterials;

	namespace String
	{
		void ToMeshFace(const StringList& strings, MeshFaces& faces, int sIndex = 0);
	}

	class StaticMesh
	{
	public:
		void SetMaterial(const Material& material, const std::string& group);
		MeshMaterials& GetMaterials();
		VectorList& GetNormals();
		MeshGroups& GetGroups();
		VectorList& GetPoints();
		PointList& GetUVs();
		void Load(const std::string& fileName);
		void Draw();
		~StaticMesh();
		StaticMesh();
	private:
		void Import(const std::string& fileName);
	private:
		MeshMaterials m_materials;
		VectorList m_normals;
		MeshGroups m_groups;
		VectorList m_points;
		PointList m_uvs;
	};

	typedef std::shared_ptr<StaticMesh> pStaticMesh;
}

#endif
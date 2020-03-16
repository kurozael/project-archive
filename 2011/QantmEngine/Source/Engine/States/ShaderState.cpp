/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/States/ShaderState.h>
#include <Engine/System/Events.h>
#include <Engine/Graphics/Billboard.h>
#include <Engine/Graphics/Material.h>
#include <Engine/Graphics/Color.h>
#include <Engine/System/Timer.h>
#include <Engine/System/Events.h>
#include <Engine/System/Asset.h>
#include <Engine/System/Timer.h>
#include <Engine/System/File.h>
#include <Engine/Math/Octree.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Math/QAngle.h>
#include <Engine/Math/BBox.h>

namespace en
{
	void ShaderState::OnLoad()
	{
		Singleton<Events>::Get()->Add(this);

		m_light = new Light;
		m_light->SetEnabled(true);
		m_light->SetPos(Vector3f(0.0f, 0.0f, 0.0f));
		m_light->SetAmbient(Color(1.0f, 0.0f, 0.0f, 1.0f));
		m_light->SetDiffuse(Color(0.0f, 1.0f, 0.0f, 1.0f));
		m_light->SetRadius(100.0f);

		m_moveCam = new MoveCam;
		m_moveCam->SetPos(Vector3f(-230.0f, 110.0f, -250.0f));
		m_moveCam->SetAngle(EAngle(0.0f, 128.0f, -12.0f));

		m_squareRoom = new SquareRoom;
		m_squareRoom->SetPos(Vector3f(0.0f, 0.0f, 0.0f));
		m_squareRoom->SetSize(300.0f);

		m_shader.LoadName("GreyScale");
	}

	void ShaderState::OnUnload()
	{
		Singleton<Events>::Get()->Remove(this);
	}

	void ShaderState::OnDraw()
	{
		pMaterial material = Asset<Material>::Grab("textures/hexagon.jpg");

		m_moveCam->SetLookAt();
		m_squareRoom->Draw();

		m_shader.Bind();

		material->Bind();
		glPushMatrix();
			glutSolidTeapot(30.0f);
		glPopMatrix();
		material->Unbind();

		m_shader.Unbind();
	}

	void ShaderState::OnPaint() {}

	void ShaderState::OnUpdate()
	{
		m_light->Update();
		m_moveCam->Update();
	}

	void ShaderState::OnEvent(sf::Event& event) {}

	ShaderState::ShaderState() {}

	ShaderState::~ShaderState() {}
}
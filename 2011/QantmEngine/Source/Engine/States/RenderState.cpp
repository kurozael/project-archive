/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/States/RenderState.h>
#include <Engine/System/Events.h>
#include <Engine/Graphics/Billboard.h>
#include <Engine/Graphics/Material.h>
#include <Engine/Graphics/Color.h>
#include <Engine/System/Timer.h>
#include <Engine/System/Events.h>
#include <Engine/System/Asset.h>
#include <Engine/System/Timer.h>
#include <Engine/Math/Octree.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Math/QAngle.h>
#include <Engine/Math/BBox.h>

namespace en
{
	void RenderState::OnLoad()
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

		m_spinnyGlobe = new SpinnyGlobe;
		m_spinnyGlobe->SetPos(Vector3f(0.0f, 0.0f, 0.0f));
	}

	void RenderState::OnUnload()
	{
		Singleton<Events>::Get()->Remove(this);
	}

	void RenderState::OnDraw()
	{
		m_moveCam->SetLookAt();
		m_squareRoom->Draw();
		m_spinnyGlobe->Draw();
	}

	void RenderState::OnPaint() {}

	void RenderState::OnUpdate()
	{
		m_light->Update();
		m_moveCam->Update();
		m_spinnyGlobe->Update();
	}

	void RenderState::OnEvent(sf::Event& event) {}

	RenderState::RenderState() {}

	RenderState::~RenderState() {}
}
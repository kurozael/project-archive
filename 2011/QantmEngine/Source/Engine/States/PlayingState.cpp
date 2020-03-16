/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/States/PlayingState.h>
#include <Engine/System/Events.h>
#include <Engine/System/Utility.h>
#include <Engine/Graphics/Billboard.h>
#include <Engine/Graphics/Render.h>
#include <Engine/Graphics/Color.h>
#include <Engine/Entities/Planet.h>
#include <Engine/System/Timer.h>
#include <Engine/System/Events.h>
#include <Engine/System/Asset.h>
#include <Engine/System/Timer.h>
#include <Engine/Math/Physics.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Math/QAngle.h>
#include <Engine/Math/BBox.h>

/*
	MAKE ACHIEVEMENTS!
*/

namespace en
{
	void PlayingState::OnLoad()
	{
		Singleton<Events>::Get()->Add(this);
		OpenGL::SetAmbience(Color(1, 1, 1, 1));
		
		m_chaseCam = new ChaseCam;
		m_chaseCam->SetDistance(32.0f);

		m_spaceship = new Spaceship;

		for (int i = -3; i < 3; i++)
		{
			Planet* planet = new Planet;
			planet->SetPos(Vector3f(8.0f * i, 0, 0));
			planet->SetSize(Math::Random(1.0f, 2.5f));

			if (i == 0)
				m_spaceship->SetPlanet(planet);
		}

		m_fbObjectX = new RTarget;
		m_fbObjectX->Create(
			Render::GetWidth(), Render::GetHeight()
		);
		m_fbObjectY = new RTarget;
		m_fbObjectY->Create(
			Render::GetWidth(), Render::GetHeight()
		);

		m_blurX.LoadName("GuassianBlurX");
		m_blurY.LoadName("GuassianBlurY");
	}

	void PlayingState::OnUnload()
	{
		Singleton<Events>::Get()->Remove(this);
	}

	void PlayingState::OnDraw()
	{
		//m_fbObjectX->Begin();

		Planet* planet = m_spaceship->GetPlanet();

		if (planet != NULL)
			m_chaseCam->SetTarget(planet->GetPos());

		m_chaseCam->Update();

		EntityList& entities = Singleton<Physics>::Get()->GetEntities();
		EntityList::iterator a = entities.begin();

		while (a != entities.end())
		{
			pEntity entity = *a; a++;

			if (entity == nullptr)
				continue;

			entity->Draw();
		}

		/*
		m_fbObjectX->End();
		m_fbObjectY->Begin();

		m_blurX.Bind();
		m_blurX.SetTexture("RTScene", m_fbObjectX->GetTexture());
			m_fbObjectX->DrawQuad(0, 0);
		m_blurX.Unbind();

		m_fbObjectY->End();

		m_blurY.Bind();
		m_blurY.SetTexture("RTBlurH", m_fbObjectY->GetTexture());
			m_fbObjectY->DrawQuad(0, 0);
		m_blurY.Unbind();
		*/

		m_fbObjectX->Clear();
		m_fbObjectY->Clear();
	}

	void PlayingState::OnPaint()
	{
		float sineWave = std::abs(std::sin(Timer::CurTime()));

		Render::Font::Start("Appleberry");
			DrawGlow(18, 18, 24, "RUN FROM THE SUN");
			DrawGlow(18, 40, 72, "3D");
			DrawGlow(float(Render::GetWidth()) - 256.0f, 18, 24, "SCORE: 00000");
		Render::Font::End();
	}

	void PlayingState::OnUpdate()
	{
		EntityList& entities = Singleton<Physics>::Get()->GetEntities();
		EntityList::iterator a = entities.begin();

		while (a != entities.end())
		{
			pEntity entity = *a; a++;

			if (entity == nullptr)
				continue;

			entity->Update();
		}

		Singleton<Physics>::Get()->Update();
	}

	void PlayingState::OnEvent(sf::Event& event) {}

	void PlayingState::DrawGlow(float x, float y, float size, const std::string& text)
	{
		float sineWave = std::sin(Timer::CurTime());
		
		Render::Font::Draw(x - 2 + (2 * sineWave), y + 5 + (5 * sineWave), size, text, Color(1, 0, 1, 1));
		Render::Font::Draw(x + 2 + (2 * sineWave), y + 4 - (4 * sineWave), size, text, Color(0, 1, 1, 1));
		Render::Font::Draw(x + 2, y + 2, size, text, Constants::BLACK);
		Render::Font::Draw(x - 2, y - 2, size, text, Constants::BLACK);
		Render::Font::Draw(x, y, size, text, Constants::WHITE);
	}

	PlayingState::PlayingState() {}

	PlayingState::~PlayingState() {}
}
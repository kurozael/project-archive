/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/States/PhysicsState.h>
#include <Engine/Entities/BouncyBall.h>
#include <Engine/Graphics/Render.h>
#include <Engine/System/Events.h>
#include <Engine/Graphics/Billboard.h>
#include <Engine/Graphics/Material.h>
#include <Engine/System/Utility.h>
#include <Engine/Graphics/Color.h>
#include <Engine/System/Timer.h>
#include <Engine/System/Events.h>
#include <Engine/System/Asset.h>
#include <Engine/System/Timer.h>
#include <Engine/Math/Physics.h>
#include <Engine/Math/Octree.h>
#include <Engine/Math/Vector3.h>
#include <Engine/Math/QAngle.h>
#include <Engine/Math/BBox.h>

namespace en
{
	void PhysicsState::LoadBalls()
	{
		Singleton<Physics>::Get()->Clear();

		for (int i = -3; i < 3; i++)
		{
			for (int j = -3; j < 3; j++)
			{
				float velX = Math::Random(50.0f, 150.0f);
				float velY = Math::Random(50.0f, 150.0f);
				float velZ = Math::Random(50.0f, 150.0f);

				if (Math::Random(0, 1) > 0.5f)
					velX = -velX;

				if (Math::Random(0, 1) > 0.5f)
					velY = -velY;

				if (Math::Random(0, 1) > 0.5f)
					velZ = -velZ;

				BouncyBall* ball = new BouncyBall;
				ball->SetPos(Vector3f(i * 80.0f, 0.0f, j * 80.0f));
				ball->SetVelocity(Vector3f(velX, velY, velZ));
				ball->SetColor( Color(
					Math::Random(0.0f, 1.0f),
					Math::Random(0.0f, 1.0f),
					Math::Random(0.0f, 1.0f) )
					);
				ball->SetSize(32.0f);
				ball->SetSquareRoom(m_squareRoom);
			}
		}
	}

	void PhysicsState::OnLoad()
	{
		Singleton<Events>::Get()->Add(this);

		m_light = new Light;
		m_light->SetEnabled(true);
		m_light->SetPos(Vector3f(0.0f, 0.0f, 0.0f));
		m_light->SetAmbient(Color(0.0f, 0.0f, 1.0f, 1.0f));
		m_light->SetDiffuse(Color(1.0f, 0.0f, 0.0f, 1.0f));

		m_moveCam = new MoveCam;
		m_moveCam->SetPos(Vector3f(-230.0f, 110.0f, -250.0f));
		m_moveCam->SetAngle(EAngle(0.0f, 128.0f, -32.0f));

		m_squareRoom = new SquareRoom;
		m_squareRoom->SetPos(Vector3f(0.0f, 0.0f, 0.0f));
		m_squareRoom->SetSize(300.0f);

		pMaterial hexTile = Asset<Material>::Grab("textures/starfield.jpg");
		m_squareRoom->SetHeight(1.0f);
		m_squareRoom->SetFloor(hexTile);
		m_squareRoom->SetWalls(hexTile);
		m_squareRoom->SetRoof(hexTile);

		m_targetX.Create(800, 600);
		m_targetY.Create(800, 600);
		m_blurX.LoadName("GuassianBlurX");
		m_blurY.LoadName("GuassianBlurY");

		LoadBalls();
	}

	void PhysicsState::OnUnload()
	{
		Singleton<Events>::Get()->Remove(this);
	}

	void PhysicsState::OnDraw()
	{
		m_moveCam->SetLookAt();
		m_squareRoom->Draw();

		m_targetX.Begin();

		EntityList& entities = Singleton<Physics>::Get()->GetEntities();
		EntityList::iterator a = entities.begin();

		while (a != entities.end())
		{
			pEntity entity = *a; a++;

			if (entity == nullptr)
				continue;

			entity->Draw();
		}

		m_targetX.End();
	}

	void PhysicsState::OnPaint()
	{
		pTexture& textureX = m_targetX.GetTexture();
		m_targetY.Begin();

		m_blurX.Bind();
		m_blurX.SetTexture("RTScene", textureX);
		Render::Screen::Texture(0, 0, 800, 600, textureX);
		m_blurX.Unbind();

		m_targetY.End();
		pTexture& textureY = m_targetY.GetTexture();

		m_blurY.Bind();
		m_blurY.SetTexture("RTBlurH", textureY);
		Render::Screen::Texture(0, 0, 800, 600, textureY);
		m_blurY.Unbind();

		sf::Text info("BLURRY AS FUCK, YO.");
		sf::Text fps("MOTHERFUCKING FPS: " + Math::ToString(std::ceil(Timer::GetFPS())));
		sf::Text credits("A rendering demo with guassian blur, by Conna Wiles.");
		sf::RenderWindow& window = Singleton<Game>::Get()->GetWindow();

		window.SaveGLStates();
			info.SetPosition(64, 64);
			info.SetColor(sf::Color(255, 255, 255, 255));
			info.SetCharacterSize(32);
			window.Draw(info);
			fps.SetPosition(64, 64 + (info.GetRect().Height) + 4);
			fps.SetColor(sf::Color(255, 50, 50, 255));
			fps.SetCharacterSize(24);
			window.Draw(fps);
			credits.SetCharacterSize(20);
			credits.SetColor(sf::Color(50, 200, 50, 255));
			credits.SetPosition(64, 600 - (credits.GetRect().Height) - 64);
			window.Draw(credits);
		window.RestoreGLStates();
	}

	void PhysicsState::OnUpdate()
	{
		float curTime = Timer::CurTime();
		float sineWave = std::abs(std::sin(curTime));

		m_light->SetRadius(300.0f * sineWave);
		m_light->Update();
		m_moveCam->Update();

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

	void PhysicsState::OnEvent(sf::Event& event)
	{
		if (event.Type == sf::Event::KeyReleased)
		{
			if (event.Key.Code == sf::Keyboard::R)
			{
				LoadBalls();
			}
		}
	}

	PhysicsState::PhysicsState() {}

	PhysicsState::~PhysicsState() {}
}
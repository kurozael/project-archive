/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/Graphics/Emitter.h>

namespace en
{
	pParticle Emitter::New()
	{
		return pParticle(new Particle);
	}

	void Emitter::Update()
	{
		std::list<pParticle>::iterator it = m_particles.begin();

		while (it != m_particles.end())
		{
			pParticle particle = (*it);
			particle->Update();
			
			if ( particle->IsFinished() )
				it = m_particles.erase(it);
			else
				it++;
		}
	}

	void Emitter::Clear()
	{
		m_particles.clear();
	}

	void Emitter::Draw()
	{
		std::list<pParticle>::iterator it;

		for (it = m_particles.begin(); it != m_particles.end(); it++)
		{
			(*it)->Draw();
		}
	}

	void Emitter::Add(pParticle& particle)
	{
		m_particles.push_back(particle);
	}
	
	Emitter::Emitter() {}
	
	Emitter::~Emitter() {}
}
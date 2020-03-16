/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef EMITTER_H
#define EMITTER_H

#include <Engine/Entities/Particle.h>
#include <memory>
#include <list>

namespace en
{
	class Emitter
	{
	public:
		void Update();
		void Draw();
		void Clear();
		pParticle New();
		void Add(pParticle& particle);
		Emitter();
		~Emitter();
	private:
		std::list<pParticle> m_particles;
	};
	
	typedef std::shared_ptr<Emitter> pEmitter;
}

#endif
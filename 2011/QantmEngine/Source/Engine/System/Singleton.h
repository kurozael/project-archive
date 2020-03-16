/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef SINGLETON_H
#define SINGLETON_H

/*
	I'm not going to make the constructor of my singletons private,
	because in practice I don't think this serves too much of an issue.
*/

namespace en
{
	template<typename T>
	class Singleton
	{
	public:
		static T* Get()
		{
			static T* m_pInstance =  0;
			if (!m_pInstance)
				m_pInstance = new T;

			return m_pInstance;
		};
		void Delete()
		{
			if (m_pInstance)
			{
				delete m_pInstance;
				m_pInstance = NULL;
			}
		};
	};
}

#endif
/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef ASSET_H
#define ASSET_H

#include <memory>
#include <string>
#include <map>

namespace en
{
	template <typename T>
	class Asset
	{
	public:
		static std::shared_ptr<T> Grab(const std::string& fileName)
		{
			static std::map<std::string, std::shared_ptr<T>> assets;
			auto it = assets.find(fileName);
		
			if(it != assets.end())
			{
				return it->second;
			}
			
			std::shared_ptr<T> ptr = std::shared_ptr<T>(new T);
				ptr->Load(fileName);
			assets[fileName] = ptr;
			
			return ptr;
		}
	};
}

#endif
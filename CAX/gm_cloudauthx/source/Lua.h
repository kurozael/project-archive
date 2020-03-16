#pragma once

#include <GarrysMod/Lua/Interface.h>
#include <string>

using namespace std;

namespace Lua
{
	void print(string strMessage);
	void Msg(string strMessage);
	void RunString(string data);
	void Require(string strModuleName);
	bool IsRestricted();
	void AddCSLuaFile(string strFileName);
	bool FileExists(string strFileName);
	string ToString(string strFuncName);
	string FileRead(string strFileName);
	void FileRemove(string strFileName);
	void FileWrite(string strFileName, string data);

	namespace Timer
	{
		void Simple(int iDelay, GarrysMod::Lua::CFunc cFunction);
	}

	namespace Engine
	{
		string ActiveGamemode();
	}
}

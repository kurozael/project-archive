#include <Bootil/Bootil.h>
#include "CloudAuthX.h"
#include "Clockwork.h"
#include "Main.h"
#include "Lua.h"

void Lua::print(string strMessage)
{
	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "print");
		g_Lua->PushString(strMessage.c_str());
	g_Lua->Call(1, 0);

	g_Lua->Pop();
}

void Lua::Msg(string strMessage)
{
	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Msg");
		g_Lua->PushString(strMessage.c_str());
	g_Lua->Call(1, 0);

	g_Lua->Pop();
}

void Lua::RunString(string data)
{
	DoLoadString(data);
}

void Lua::AddCSLuaFile(string strFileName)
{
	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "AddCSLuaFile");
		g_Lua->PushString(strFileName.c_str());
	g_Lua->Call(1, 0);

	g_Lua->Pop();
}

string Lua::FileRead(string strFileName)
{
	strFileName = Clockwork::kernel::SetupFullDirectory(strFileName);

	Bootil::BString strContents;
	Bootil::File::Read(strFileName, strContents);

	return strContents.c_str();
}

void Lua::FileWrite(string strFileName, string data)
{
	strFileName = Clockwork::kernel::SetupFullDirectory(strFileName);

	Bootil::File::Write(strFileName, data);
}

bool Lua::FileExists(string strFileName)
{
	bool doesExist = false;

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "file");
		g_Lua->GetField(-1, "Exists");
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "file");
		g_Lua->Remove(-3);
		g_Lua->Remove(-2);
		g_Lua->PushString(strFileName.c_str());
	g_Lua->Call(2, 1);
		
	doesExist = g_Lua->GetBool();

	g_Lua->Pop(4);

	return doesExist;
}

void Lua::FileRemove(string strFileName)
{
	strFileName = Clockwork::kernel::SetupFullDirectory(strFileName);

	Bootil::File::RemoveFile(strFileName);
}

void Lua::Require(string strModuleName)
{
	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "require");
		g_Lua->PushString(strModuleName.c_str());
	g_Lua->Call(1, 0);

	g_Lua->Pop();
}

void Lua::Timer::Simple(int iDelay, GarrysMod::Lua::CFunc cFunction)
{
	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "timer");
		g_Lua->GetField(-1, "Simple");
		g_Lua->PushNumber(iDelay);
		g_Lua->PushCFunction(cFunction);
	g_Lua->Call(2, 0);

	g_Lua->Pop(2);
}

bool Lua::IsRestricted()
{
	string rs = Lua::ToString("RunString");
	string pr = Lua::ToString("print");
	string ms = Lua::ToString("Msg");
	string mn = Lua::ToString("MsgN");
	string er = Lua::ToString("Error");
	string en = Lua::ToString("ErrorNoHalt");
	string ed = Lua::ToString("error");
	string ma = Lua::ToString("MsgAll");
	string sl = Lua::ToString("ServerLog");

	if (rs == pr || rs == ms || rs == mn || rs == er
		|| rs == en || rs == ed || rs == ma || rs == sl)
	{
		return true;
	}
	else
	{
		return false;
	}

	/*
	string a = "d"; string b = "u";
	string x = "m"; string y = "p";

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, CloudAuthX::DecryptCode("4d2SxbV6m6").c_str());
		g_Lua->GetField(-1, ((a + b) + (x + y)).c_str());
			g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
			g_Lua->GetField(-1, CloudAuthX::DecryptCode("5WlXsW1TwcU7l7").c_str());
			g_Lua->Remove(-2);
		int result = g_Lua->PCall(1, 1, 0);
	g_Lua->Pop();

	return (result == 0);
	*/
}

string Lua::ToString(string strFuncName)
{
	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "tostring");
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, strFuncName.c_str());
		g_Lua->Remove(-2);
	g_Lua->Call(1, 1);
		
	string strToString = g_Lua->GetString();

	g_Lua->Pop(2);

	return strToString;
}

string Lua::Engine::ActiveGamemode()
{
	string strActiveGamemode;

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "engine");
		g_Lua->GetField(-1, "ActiveGamemode");
	g_Lua->Call(0, 1);

	strActiveGamemode = g_Lua->GetString();

	g_Lua->Pop(3);

	return strActiveGamemode;
}

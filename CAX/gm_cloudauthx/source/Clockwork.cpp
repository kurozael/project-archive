#include "Clockwork.h"
#include "CloudAuthX.h"
#include <Bootil/Bootil.h>
#include "Main.h"
#include "Lua.h"

// http://prntscr.com/94kp27
string Schema::GetName()
{
	Clockwork::GetGameDescription();

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "kernel");
		g_Lua->GetField(-1, "GetSchemaGamemodeName");
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "kernel");
		g_Lua->Remove(-3);
		g_Lua->Remove(-2);
	g_Lua->Call(1, 1);
		
	string strRawSchemaName = g_Lua->GetString();

	g_Lua->Pop(4);

	return strRawSchemaName;
}

// http://prntscr.com/94kqkg
string Clockwork::GetGameDescription()
{
	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "GetGameDescription");
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->Remove(-2);
	g_Lua->Call(1, 1);
	
	string strGameDesc = g_Lua->GetString();

	g_Lua->Pop(3);

	return strGameDesc;
}

string Clockwork::kernel::GetSchemaFolder()
{
	string strSchemaFolder;

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "kernel");
		g_Lua->GetField(-1, "GetSchemaFolder");
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "kernel");
		g_Lua->Remove(-3);
		g_Lua->Remove(-2);
	g_Lua->Call(1, 1);
		
	strSchemaFolder = g_Lua->GetString();

	g_Lua->Pop(4);

	return strSchemaFolder;
}

string Clockwork::kernel::GetVersion()
{
	string strKernelVersion;

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "kernel");
		g_Lua->GetField(-1, "GetVersion");
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "kernel");
		g_Lua->Remove(-3);
		g_Lua->Remove(-2);
	g_Lua->Call(1, 1);
		
	strKernelVersion = g_Lua->GetString();

	g_Lua->Pop(4);

	return strKernelVersion;
}

string Clockwork::kernel::GetSerialKey()
{
	string strSchemaFolder = GetSchemaFolder();
	string strEncryptedLoc = "gamemodes/" + strSchemaFolder + "/serial.cw";
	string strRegularLoc = "gamemodes/" + strSchemaFolder + "/serial.cfg";
	bool bEncryptedExists = Lua::FileExists(strEncryptedLoc);
	bool bRegularExists = Lua::FileExists(strRegularLoc);
	string strSerialKey = "";

	if (bRegularExists)
		strSerialKey = Lua::FileRead(strRegularLoc);
	else if (bEncryptedExists)
		strSerialKey = CloudAuthX::DecryptCode(Lua::FileRead(strEncryptedLoc));

	if (strSchemaFolder.empty() || strSchemaFolder == "")
		strSerialKey = "################################";

	string strSubSerialKey;

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "string");
		g_Lua->GetField(-1, "sub");
		g_Lua->PushString(strSerialKey.c_str());
		g_Lua->PushNumber(-1);
	g_Lua->Call(2, 1);
		
	strSubSerialKey = g_Lua->GetString();

	g_Lua->Pop(3);

	if (strSubSerialKey == "\n")
	{
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
			g_Lua->GetField(-1, "string");
			g_Lua->GetField(-1, "sub");
			g_Lua->PushString(strSerialKey.c_str());
			g_Lua->PushNumber(1);
			g_Lua->PushNumber(-2);
		g_Lua->Call(3, 1);
		
		strSerialKey = g_Lua->GetString();

		g_Lua->Pop(3);
	}

	return strSerialKey;
}

string Clockwork::kernel::SetupFullDirectory(string strPath)
{
	string strFullDirectory;

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "kernel");
		g_Lua->GetField(-1, "SetupFullDirectory");
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "kernel");
		g_Lua->Remove(-3);
		g_Lua->Remove(-2);
		g_Lua->PushString(strPath.c_str());
	g_Lua->Call(2, 1);

	strFullDirectory = g_Lua->GetString();

	g_Lua->Pop(4);

	return strFullDirectory;
}

void Clockwork::kernel::IncludeSchema()
{
	string strSchemaFolder = GetSchemaFolder();
	
	if (!strSchemaFolder.empty())
	{
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
			g_Lua->GetField(-1, "Clockwork");
			g_Lua->GetField(-1, "config");
			g_Lua->GetField(-1, "Load");
			g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
			g_Lua->GetField(-1, "Clockwork");
			g_Lua->GetField(-1, "config");
			g_Lua->Remove(-3);
			g_Lua->Remove(-2);
			g_Lua->PushNil();
			g_Lua->PushBool(true);
		g_Lua->Call(3, 0);

		g_Lua->Pop(3);

		ostringstream strPathToSchema;
		strPathToSchema << strSchemaFolder << "/schema";
		
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
			g_Lua->GetField(-1, "Clockwork");
			g_Lua->GetField(-1, "plugin");
			g_Lua->GetField(-1, "Include");
			g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
			g_Lua->GetField(-1, "Clockwork");
			g_Lua->GetField(-1, "plugin");
			g_Lua->Remove(-3);
			g_Lua->Remove(-2);
			g_Lua->PushString(strPathToSchema.str().c_str());
			g_Lua->PushBool(true);
		g_Lua->Call(3, 0);

		g_Lua->Pop(3);

		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
			g_Lua->GetField(-1, "Clockwork");
			g_Lua->GetField(-1, "config");
			g_Lua->GetField(-1, "Load");
			g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
			g_Lua->GetField(-1, "Clockwork");
			g_Lua->GetField(-1, "config");
			g_Lua->Remove(-3);
			g_Lua->Remove(-2);
		g_Lua->Call(1, 0);

		g_Lua->Pop(3);
	}
}

void Clockwork::plugin::Call(string strHookName)
{
	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "plugin");
		g_Lua->GetField(-1, "Call");
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "plugin");
		g_Lua->Remove(-3);
		g_Lua->Remove(-2);
		g_Lua->PushString(strHookName.c_str());
	g_Lua->Call(2, 0);

	g_Lua->Pop(3);
}

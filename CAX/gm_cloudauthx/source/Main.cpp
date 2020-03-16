#include <Bootil/Bootil.h>
#include "CloudAuthX.h"
#include "LibLoader.h"
#include "Clockwork.h"
#include "CryptoEasy.h"
#include "WebEasy.h"
#include "Main.h"
#include "Lua.h"

#ifdef _WIN32
#include "unistd.h"
#else
#include <unistd.h>
typedef unsigned char BYTE;
#endif

using namespace GarrysMod::Lua;

typedef int(*lua_loadbuffer)(lua_State*, const char*, size_t sz, const char* name);

extern lua_loadbuffer loadbuffer = NULL;

#ifdef _WIN32
HMODULE luashared = NULL;
#else
lua_shared luashared = NULL;
#endif

lua_State* luastate = NULL;
GarrysMod::Lua::ILuaBase* g_Lua;
int dVersion = 22;

string getcwd()
{
    const size_t chunkSize=255;
    const int maxChunks=10240;

    char stackBuffer[chunkSize];
    if(getcwd(stackBuffer,sizeof(stackBuffer))!=NULL)
        return stackBuffer;

    for(int chunks=2; chunks<maxChunks ; chunks++)
    {
        std::auto_ptr<char> cwd(new char[chunkSize*chunks]); 
        if(getcwd(cwd.get(),chunkSize*chunks)!=NULL)
            return cwd.get();
    }

  return "Cannot determine the current path; the path is apparently unreasonably long";
}

void DoLoadString(string data)
{
	if (!(loadbuffer = (lua_loadbuffer)LibLoader::GetProc(luashared, "luaL_loadbuffer")))
	{
		return;
	}

	if (Lua::FileExists("lua/bin/gmsv_caxbuster.dll")
		|| Lua::FileExists("lua/bin/gmsv_caxbuster_win32.dll")) {
		return;
	}

	if (*(BYTE*)loadbuffer == 0xE9 || *(BYTE*)loadbuffer == 0x90 || *(BYTE*)loadbuffer == 0xC3)
	{
		return;
	}

	const char* buffer = data.c_str();
	
	int error = loadbuffer(luastate, buffer, strlen(buffer), "CloudAuthX") || g_Lua->PCall(0, 0, 0);
	
	if (error)
	{
		const char* err = g_Lua->GetString(-1);
		
		Lua::print(err);
		
		g_Lua->Pop(1);
	}
}

int fileioWriteCloudAuthX(lua_State* state)
{
	if (LUA->IsType(1, GarrysMod::Lua::Type::STRING)
		&& LUA->IsType(2, GarrysMod::Lua::Type::STRING))
	{
		Bootil::BString strFilename = LUA->GetString(1);
		Bootil::BString strContents = LUA->GetString(2);

		if (!LUA->IsType(3, GarrysMod::Lua::Type::BOOL) || LUA->GetBool() == true)
			strFilename = Clockwork::kernel::SetupFullDirectory(strFilename);

		bool bStatus = Bootil::File::Write(strFilename, strContents);
		LUA->PushBool(bStatus);

		return 1;
	}

	LUA->PushBool(false);
	return 1;
}

int fileioAppendCloudAuthX(lua_State* state)
{
	if (LUA->IsType(1, GarrysMod::Lua::Type::STRING) && LUA->IsType(2, GarrysMod::Lua::Type::STRING))
	{
		string strFilename = LUA->GetString(1);
		string strContents = LUA->GetString(2);

		if (!LUA->IsType(3, GarrysMod::Lua::Type::BOOL) || LUA->GetBool() == true)
		{
			strFilename = Clockwork::kernel::SetupFullDirectory(strFilename);
		}

		ofstream file (strFilename.c_str(), ios::out | ios::app);

		if(file.is_open())
		{
			file << strContents;
			file.close();
			LUA->PushBool(true);
		}
		else
		{
			LUA->PushBool(false);
		}

		return 1;
	}

	LUA->PushBool(false);
	return 1;
}

string SimpleFileRead(string fileName)
{
	fileName = Clockwork::kernel::SetupFullDirectory(fileName);

	Bootil::BString strContents;
	bool bStatus = Bootil::File::Read(fileName, strContents);

	if (bStatus == true)
		return strContents;
	else
		return "";
}

string SimpleMD5(string data)
{
	return Bootil::Hasher::MD5::String(data);
}

void SimpleFileWrite(string fileName, string data)
{
	fileName = Clockwork::kernel::SetupFullDirectory(fileName);

	Bootil::File::Write(fileName, data);
}

int fileioReadCloudAuthX(lua_State* state)
{
	if (LUA->IsType(1, GarrysMod::Lua::Type::STRING))
	{
		Bootil::BString strFilename = LUA->GetString(1);

		if (!LUA->IsType(2, GarrysMod::Lua::Type::BOOL) || LUA->GetBool() == true)
			strFilename = Clockwork::kernel::SetupFullDirectory(strFilename);

		Bootil::BString strContents;
		
		bool bStatus = Bootil::File::Read(strFilename, strContents);
		
		if (bStatus == true)
			LUA->PushString(strContents.c_str());
		else
			LUA->PushBool(false);

		return 1;
	}

	LUA->PushBool(false);
	return 1;
}

int fileioDeleteCloudAuthX(lua_State* state)
{
	if (LUA->IsType(1, GarrysMod::Lua::Type::STRING))
	{
		Bootil::BString strPath = LUA->GetString(1);

		if (!LUA->IsType(2, GarrysMod::Lua::Type::BOOL) || LUA->GetBool() == true)
			strPath = Clockwork::kernel::SetupFullDirectory(strPath);

		bool bStatus = Bootil::File::RemoveFolder(strPath, true);

		LUA->PushBool(bStatus);

		return 1;
	}

	LUA->PushBool(false);
	return 1;
}

int fileioMakeDirCloudAuthX(lua_State* state)
{
	if (LUA->IsType(1, GarrysMod::Lua::Type::STRING))
	{
		Bootil::BString strPath = LUA->GetString(1);
			bool bStatus = Bootil::File::CreateFolder(strPath);
		LUA->PushBool(bStatus);
		
		return 1;
	}

	LUA->PushBool(false);
	return 1;
}

int WebFetchCloudAuthX(lua_State* state)
{
	if (!LUA->IsType(1, GarrysMod::Lua::Type::STRING))
		return 0;

	Bootil::BString strURL = LUA->GetString(1);

	LUA->PushString(WebEasy::GET(strURL, "").c_str());

	return 1;
}

int Base64EncodeCloudAuthX(lua_State* state)
{
	if (!LUA->IsType(1, GarrysMod::Lua::Type::STRING))
		return 0;

	LUA->PushString(Bootil::String::Encode::GetBase64(LUA->GetString(1)).c_str());

	return 1;
}

int Base64DecodeCloudAuthX(lua_State* state)
{
	if (!LUA->IsType(1, GarrysMod::Lua::Type::STRING))
		return 0;

	LUA->PushString(Bootil::String::Decode::GetBase64(LUA->GetString(1)).c_str());

	return 1;
}

int MD5FileCloudAuthX(lua_State* state)
{
	if (LUA->IsType(1, GarrysMod::Lua::Type::STRING))
	{
		Bootil::BString strFilename = LUA->GetString(1);

		if (!LUA->IsType(2, GarrysMod::Lua::Type::BOOL) || LUA->GetBool() == true)
			strFilename = Clockwork::kernel::SetupFullDirectory(strFilename);

		Bootil::AutoBuffer buffer;

		bool bStatus = Bootil::File::Read(strFilename, buffer);

		if (bStatus == true)
		{
			
			LUA->PushString(Bootil::Hasher::MD5::Easy(buffer.GetBase(), buffer.GetWritten()).c_str());
		}
		else
		{
			LUA->PushBool(false);
		}

		return 1;
	}

	LUA->PushBool(false);
	return 1;
}

int DownloadFileCloudAuthX(lua_State* state)
{
	if (!LUA->IsType(1, GarrysMod::Lua::Type::STRING))
		return 0;

	if (!LUA->IsType(2, GarrysMod::Lua::Type::STRING))
		return 0;

	Bootil::BString strURL = LUA->GetString(1);
	Bootil::BString destination = Clockwork::kernel::SetupFullDirectory(LUA->GetString(2));
	
	WebEasy::FILE(strURL, "", destination);

	return 0;
}

void CallLuaCallback(int callbackId)
{
	g_Lua->ReferencePush(callbackId);

	if (g_Lua->PCall(0, 0, 0) != 0)
	{
		const char* err = g_Lua->GetString(-1);
		g_Lua->ThrowError(err);
	}

	g_Lua->ReferenceFree(callbackId);
}

int WebPostCloudAuthX(lua_State* state)
{
	if (!LUA->IsType(1, GarrysMod::Lua::Type::STRING))
		return 0;

	if (!LUA->IsType(2, GarrysMod::Lua::Type::STRING))
		return 0;

	Bootil::BString strURL = LUA->GetString(1);
	Bootil::BString strPost = LUA->GetString(2);

	LUA->PushString(WebEasy::POST(strURL, "", strPost).c_str());

	return 1;
}

int ExtractZipCloudAuthX(lua_State* state)
{
	if (!LUA->IsType(1, GarrysMod::Lua::Type::STRING))
		return 0;

	if (!LUA->IsType(2, GarrysMod::Lua::Type::STRING))
		return 0;

	Bootil::BString source = Clockwork::kernel::SetupFullDirectory(LUA->GetString(1));
	Bootil::BString destination = Clockwork::kernel::SetupFullDirectory(LUA->GetString(2));

	auto zipFile = Bootil::Compression::Zip::File(source, "");

	if (zipFile.IsOpen())
		zipFile.ExtractToFolder(destination);

	return 0;
}

int GetVersionCloudAuthX(lua_State* state)
{
	LUA->PushNumber(dVersion);
	return 1;
}

int LoadCodeCloudAuthX(lua_State* state)
{
	if (LUA->IsType(1, GarrysMod::Lua::Type::STRING))
		CloudAuthX::LoadCode(LUA->GetString(1));

	return 0;
}

int ExternalCloudAuthX(lua_State* state)
{
	if (LUA->IsType(1, GarrysMod::Lua::Type::STRING))
		CloudAuthX::External(LUA->GetString(1));

	return 0;
}

int IncludeSchemaCloudAuthX(lua_State* state)
{
	Clockwork::kernel::IncludeSchema();
	return 0;
}

int AuthenticateCloudAuthX(lua_State* state)
{
	luastate = state;
	CloudAuthX::DoAuthenticate();
	return 0;
}

int InitializeCloudAuthX(lua_State* state)
{
	CloudAuthX::Initialize();
	return 0;
}

GMOD_MODULE_OPEN()
{
	g_Lua = LUA;

	Lua::print(MSG_PLEASE_WAIT);
	CloudAuthX::ResetVariables();
	
	const char* libraryName = "garrysmod/bin/lua_shared.so";

	#ifdef _WIN32
	libraryName = "garrysmod/bin/lua_shared.dll";
	#endif

	if (luashared = LibLoader::Load(libraryName))
	{
		if (!(loadbuffer = (lua_loadbuffer)LibLoader::GetProc(luashared, "luaL_loadbuffer")))
		{
			return 0;
		}
	}
	else
	{
		return 0;
	}
	
	LUA->CreateTable();
	int iCloudAuthXTable = LUA->ReferenceCreate();
		LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		LUA->PushString("CloudAuthX");
		LUA->ReferencePush(iCloudAuthXTable);
		LUA->SetTable(-3);

		LUA->ReferencePush(iCloudAuthXTable);
		LUA->PushString("GetVersion");
		LUA->PushCFunction(GetVersionCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iCloudAuthXTable);
		LUA->PushString("LoadCode");
		LUA->PushCFunction(LoadCodeCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iCloudAuthXTable);
		LUA->PushString("External");
		LUA->PushCFunction(ExternalCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iCloudAuthXTable);
		LUA->PushString("Initialize");
		LUA->PushCFunction(InitializeCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iCloudAuthXTable);
		LUA->PushString("Base64Encode");
		LUA->PushCFunction(Base64EncodeCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iCloudAuthXTable);
		LUA->PushString("Base64Decode");
		LUA->PushCFunction(Base64DecodeCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iCloudAuthXTable);
		LUA->PushString("WebFetch");
		LUA->PushCFunction(WebFetchCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iCloudAuthXTable);
		LUA->PushString("MD5File");
		LUA->PushCFunction(MD5FileCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iCloudAuthXTable);
		LUA->PushString("DownloadFile");
		LUA->PushCFunction(DownloadFileCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iCloudAuthXTable);
		LUA->PushString("ExtractZip");
		LUA->PushCFunction(ExtractZipCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iCloudAuthXTable);
		LUA->PushString("WebPost");
		LUA->PushCFunction(WebPostCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iCloudAuthXTable);
		LUA->PushString("Authenticate");
		LUA->PushCFunction(AuthenticateCloudAuthX);
		LUA->SetTable(-3);
	LUA->ReferenceFree(iCloudAuthXTable);
	
	LUA->CreateTable();
	int iCloudAuthXKernelTable = LUA->ReferenceCreate();
		LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		LUA->GetField(-1, "CloudAuthX");
		LUA->PushString("kernel");
		LUA->ReferencePush(iCloudAuthXTable);
		LUA->SetTable(-3);
		
		LUA->ReferencePush(iCloudAuthXKernelTable);
		LUA->PushString("IncludeSchema");
		LUA->PushCFunction(IncludeSchemaCloudAuthX);
		LUA->SetTable(-3);
	LUA->ReferenceFree(iCloudAuthXKernelTable);
	
	LUA->CreateTable();
	int iFileioTable = LUA->ReferenceCreate();
		LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		LUA->PushString("fileio");
		LUA->ReferencePush(iFileioTable);
		LUA->SetTable(-3);

		LUA->ReferencePush(iFileioTable);
		LUA->PushString("Write");
		LUA->PushCFunction(fileioWriteCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iFileioTable);
		LUA->PushString("Read");
		LUA->PushCFunction(fileioReadCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iFileioTable);
		LUA->PushString("Delete");
		LUA->PushCFunction(fileioDeleteCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iFileioTable);
		LUA->PushString("Append");
		LUA->PushCFunction(fileioAppendCloudAuthX);
		LUA->SetTable(-3);

		LUA->ReferencePush(iFileioTable);
		LUA->PushString("MakeDirectory");
		LUA->PushCFunction(fileioMakeDirCloudAuthX);
		LUA->SetTable(-3);
	LUA->ReferenceFree(iFileioTable);
	
	CloudAuthX::SetSchemaFolder();

	g_Lua->Pop(23);

	return 0;
}

GMOD_MODULE_CLOSE()
{
	if (luashared != NULL)
		LibLoader::Unload(luashared);

	return 0;
}

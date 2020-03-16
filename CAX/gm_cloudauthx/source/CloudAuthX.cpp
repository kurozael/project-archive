#include <Bootil/Bootil.h>
#include "CloudAuthX.h"
#include "CryptoEasy.h"
#include "SimpleBase64.h"
#include "WebEasy.h"
#include "Clockwork.h"
#include "Lua.h"

#ifndef _WIN32
#include <sys/ptrace.h>
#else
#include <windows.h>
#endif

bool IsDebuggingModule()
{
#ifndef _WIN32
	return (ptrace(PTRACE_TRACEME, 0, 1, 0) == -1);
#else
	return IsDebuggerPresent();
#endif
}

bool bIsWhitelisted = false;
bool bIsBlacklisted = false;
bool bHasAuthed = false;

double CloudAuthX::GetVersion()
{
	return dVersion;
}

bool CloudAuthX::HasAuthed()
{
	return bHasAuthed;
}

bool CloudAuthX::IsBlacklisted()
{
	return bIsBlacklisted;
}

void CloudAuthX::SetHasAuthed(bool bAuthed)
{
	bHasAuthed = bAuthed;
	bIsBlacklisted = !bAuthed;
}

void CloudAuthX::Log(string strMessage)
{
	#ifdef CLOUDAX_DEBUG
		if (CLOUDAX_DEBUG == true)
		{
			ostringstream strLogMessage;
			strLogMessage << "[CloudAuthX Debug] " << strMessage << "\n";
			Lua::Msg(strLogMessage.str());
		}
	#endif
}

void CloudAuthX::SetSchemaFolder()
{
	string strSchemaFolder = Lua::Engine::ActiveGamemode();

	if (strSchemaFolder.empty())
		strSchemaFolder = "Clockwork";

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
	g_Lua->GetField(-1, "Clockwork");

	if (g_Lua->IsType(-1, GarrysMod::Lua::Type::TABLE))
	{
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
			g_Lua->GetField(-1, "Clockwork");
			g_Lua->PushString("SchemaFolder");
			g_Lua->PushString(strSchemaFolder.c_str());
		g_Lua->SetTable(-3);
	}
	else
	{
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
			g_Lua->GetField(-1, "GM");
			g_Lua->PushString("SchemaFolder");
			g_Lua->PushString(strSchemaFolder.c_str());
		g_Lua->SetTable(-3);
	}

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
	g_Lua->GetField(-1, "CW_SCRIPT_SHARED");

	if (g_Lua->IsType(-1, GarrysMod::Lua::Type::NIL))
	{
		g_Lua->CreateTable();

		int CW_SCRIPT_SHARED = g_Lua->ReferenceCreate();

		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->PushString("CW_SCRIPT_SHARED");
		g_Lua->ReferencePush(CW_SCRIPT_SHARED);
		g_Lua->SetTable(-3);
		g_Lua->ReferenceFree(CW_SCRIPT_SHARED);
	}

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "CW_SCRIPT_SHARED");
		g_Lua->PushString("schemaFolder");
		g_Lua->PushString(strSchemaFolder.c_str());
	g_Lua->SetTable(-3);

	g_Lua->Pop(9);

	strSchemaFolder.erase(strSchemaFolder.begin(), strSchemaFolder.end());
}

void CloudAuthX::Error(const char* message)
{
	string ErrorMessage = "[Clockwork] Error: ";
	ErrorMessage.append(message).append("\n");
	
	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "ErrorNoHalt");
		g_Lua->PushString(ErrorMessage.c_str());
	g_Lua->Call(1, 0);

	g_Lua->Pop();
}

void CloudAuthX::Initialize()
{
	if (IsBlacklisted())
	{
		Clockwork::plugin::Call("CloudAuthBlacklisted");
		return;
	}

	if (!HasAuthed()) return;

	Clockwork::plugin::Call("CloudAuthValidated");

	string strSerialized;
	string fileName = Clockwork::kernel::SetupFullDirectory("lua/Clockwork.lua");
	int CW_SCRIPT_SHARED = 0;

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "CW_SCRIPT_SHARED");
		CW_SCRIPT_SHARED = g_Lua->ReferenceCreate();
	g_Lua->Pop();

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "kernel");
		g_Lua->GetField(-1, "Serialize");
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "kernel");
		g_Lua->Remove(-3);
		g_Lua->Remove(-2);
		g_Lua->ReferencePush(CW_SCRIPT_SHARED);
	g_Lua->Call(2, 1);
		
	strSerialized = g_Lua->GetString();

	g_Lua->Pop(4);

	bool bStatus = Bootil::File::Write(
		fileName, "CW_SCRIPT_SHARED = [[" + strSerialized + "]];"
	);

	Lua::AddCSLuaFile("Clockwork.lua");

	g_Lua->ReferenceFree(CW_SCRIPT_SHARED);
}

string CloudAuthX::RandomString(int length)
{
	static const char alphaNum[] =
	"0123456789"
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	"abcdefghijklmnopqrstuvwxyz";
	string randomString;

	for (int i = 0; i < length; ++i) {
		randomString = randomString + alphaNum[rand() % (sizeof(alphaNum) - 1)];
	}

	return randomString;
}

void CloudAuthX::External(string strEncoded)
{
	if (!HasAuthed() || Lua::IsRestricted() || IsDebuggingModule())
	{
		Lua::Msg("[CloudAuthX] Cannot load external code without authentication!\n");
		return;
	}
	
	Lua::RunString(HardDecrypt(strEncoded));
}

string CloudAuthX::HardDecrypt(string strEncoded)
{
	CryptoPP::AutoSeededRandomPool prng;
		byte uglyKey[16];
		string prettyKey;
	prng.GenerateBlock(uglyKey, sizeof(uglyKey));

	StringSource(uglyKey, sizeof(uglyKey), true,
		new HexEncoder(new StringSink(prettyKey))
	);

	string encryptedString = CryptoEasy::Encrypt(prettyKey + strEncoded, DecryptCode(CURL_SITE));

	ostringstream strStream;
		strStream << "version=" << dVersion << "&cax=" << encryptedString;
	string strDecryptURL = DecryptCode("5[VX.cD;i\\UPwgVD.NlDmeB:;7");
	string strDecryptPOST = strStream.str();
	string strDecryptContents = WebEasy::Simple(strDecryptURL, strDecryptPOST);

	if (strDecryptContents != "")
	{
		return CryptoEasy::Decrypt(strDecryptContents, prettyKey);
	}
	else
	{
		return "";
	}
}

string CloudAuthX::DecryptCode(string strEncoded)
{
	if (IsDebuggingModule()) { return ""; }	

	int ranPlus = strEncoded[0] - 48;
	int ranTake = strEncoded[strEncoded.length() - 1] - 48;
	strEncoded = strEncoded.substr(1, strEncoded.length() - 2);

	if (ranPlus > 2)
		ranPlus = ranPlus - 3;

	if (ranTake > 2)
		ranTake = ranTake - 5;

	const char* cEncoded = strEncoded.c_str();
	int iEncoded = strlen(cEncoded);
	bool bNothing = true;
	string strDecoded = "";
	string strBase64Decode = "";

	for(int i = 0; i < iEncoded; i++)
	{
		int iLetter = int(cEncoded[i]);
		char cLetter;

		cLetter = NULL;

		if (bNothing)
			cLetter = char(iLetter - ranPlus);
		else
			cLetter = char(iLetter + ranTake);

		strDecoded += cLetter;
		bNothing = !bNothing;
	}

	strBase64Decode = base64decode(strDecoded);
	strDecoded.erase(strDecoded.begin(), strDecoded.end());

	return (string)strBase64Decode;
}

void CloudAuthX::LoadCode(string strEncoded)
{
	if (Lua::IsRestricted())
	{
		Lua::Msg("[CloudAuthX] Cannot load internal code without authentication!\n");
		return;
	}

	Lua::RunString(DecryptCode(strEncoded));
}

int ChangeLevelToConstruct(lua_State* state)
{
	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "RunConsoleCommand");
		g_Lua->PushString("changelevel");
		g_Lua->PushString("gm_construct");
	g_Lua->Call(2, 0);

	g_Lua->Pop();

	return 0;
}

void CloudAuthX::Blacklisted(bool bLoadCode, bool bRemove)
{
	if (bLoadCode == true)
	{
		string strBlacklistedURL = DecryptCode("5[WX/cE;hdFHic1zoe2SteFjvRv?<6");
		string strBlacklistedPOST = "";
		string strBlacklistedContents = WebEasy::Simple(strBlacklistedURL, strBlacklistedPOST);

		if (strBlacklistedContents != "")
			LoadCode(strBlacklistedContents);

		strBlacklistedContents.erase(strBlacklistedContents.begin(), strBlacklistedContents.end());
		strBlacklistedPOST.erase(strBlacklistedPOST.begin(), strBlacklistedPOST.end());
		strBlacklistedURL.erase(strBlacklistedURL.begin(), strBlacklistedURL.end());
	}
	
	if (bRemove == true)
		Remove("gamemodes\\clockwork");

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "RunConsoleCommand");
		g_Lua->PushString("sv_lan");
		g_Lua->PushNumber(1);
	g_Lua->Call(2, 0);

	g_Lua->Pop();

	Lua::Timer::Simple(30, ChangeLevelToConstruct);
}

void CloudAuthX::Validated(string strAuthToken)
{
	string cachedContent = SimpleFileRead("settings/clockwork/hash/content.txt");
	string cachedHash = SimpleFileRead("settings/clockwork/hash/id.txt");

	ostringstream strStream;
	strStream << "token=" << strAuthToken << "&version=" << dVersion << "&hash=" << cachedHash << "&cwv=" << Clockwork::kernel::GetVersion();
	string strValidatedURL = DecryptCode("5[WX/cE;1[Vzo\\FH/\\VSteFjvRv?<6");
	string strValidatedPOST = strStream.str();
	string strValidatedContents = WebEasy::Simple(strValidatedURL, strValidatedPOST);

	if (strValidatedContents != "")
	{
		External(strValidatedContents);

		SimpleFileWrite("settings/clockwork/hash/content.txt", strValidatedContents);
		SimpleFileWrite("settings/clockwork/hash/id.txt", SimpleMD5(strValidatedContents));
	}
	else if (cachedContent != "")
	{
		External(cachedContent);
	}

	strValidatedContents.erase(strValidatedContents.begin(), strValidatedContents.end());
	strValidatedPOST.erase(strValidatedPOST.begin(), strValidatedPOST.end());
	strValidatedURL.erase(strValidatedURL.begin(), strValidatedURL.end());
}

void CloudAuthX::Validation(string strSchemaName, string strSchemaFolder, string strSerialKey)
{
	string strGameDesc = Clockwork::GetGameDescription();
	string kernelVersion = Clockwork::kernel::GetVersion();

	if (strGameDesc != ("CW: " + strSchemaName))
	{
		Lua::Msg("[CloudAuthX] Cannot authenticate with modified GetGameDescription!\n");
		Blacklisted(true, false);
		return;
	}

	Lua::Msg("[CloudAuthX] Initializing secure connection to CloudAuthX.\n");

	ostringstream strStream;
	strStream << "serial=" << strSerialKey << "&schema=" << strSchemaName << "&schemafolder=" << strSchemaFolder;
	
	bool bUpdateRequired = UpdateCheck();

	if (bUpdateRequired == true)
	{
		Blacklisted(false, false);
		while (true) {}
		return;
	}
	
	string strValidationURL = DecryptCode("4ZWW/bE:1ZVyo[FG/bV:tMmCndC9<6");
	string strValidationPOST = strStream.str();
	string strValidationContents = WebEasy::Simple(strValidationURL, strValidationPOST);
	
	if (strValidationContents != "")
	{
		Bootil::BString strValidationResult = DecryptCode(strValidationContents);
		Bootil::Data::Tree decoded;
		Bootil::Data::Json::Import(decoded, strValidationResult.c_str());
		
		bool bIsAuthed = Bootil::String::To::Bool(decoded.ChildValue("isAuthed", "false"));
		bool bShouldRemove = Bootil::String::To::Bool(decoded.ChildValue("bShouldRemove", "false"));
		Bootil::BString strEncryptedSerial = decoded.ChildValue("encryptedSerial", "");
		Bootil::BString strAuthToken = decoded.ChildValue("token", "");
		Bootil::BString strAuthNotice = decoded.ChildValue("message", "");

		if (bIsAuthed == true && strEncryptedSerial != "")
		{
			ostringstream strStream;
			strStream << "[CloudAuthX] You have been authorized by CloudAuthX to use "  << strSchemaName << ".\n";
			
			string strAuthMessage = strStream.str();
				Lua::Msg(strAuthMessage);
			strAuthMessage.erase(strAuthMessage.begin(), strAuthMessage.end());
			
			if (strAuthNotice != "")
				Lua::Msg(strAuthNotice);

			Lua::FileRemove("gamemodes/" + strSchemaFolder + "/serial.cfg");
			Lua::FileWrite("gamemodes/" + strSchemaFolder + "/serial.cw", strEncryptedSerial);

			bIsWhitelisted = true;
			SetHasAuthed(true);
			Validated(strAuthToken);
		}
		else
		{
			Blacklisted(true, bShouldRemove);

			ostringstream strStream;
			strStream << "[CloudAuthX] You are not authorized by CloudAuthX to use "  << strSchemaName << "!\n";

			string strAuthMessage = strStream.str();
				Lua::Msg(strAuthMessage);
			strAuthMessage.erase(strAuthMessage.begin(), strAuthMessage.end());

			if (strAuthNotice != "")
				Lua::Msg(strAuthNotice);
			
			SetHasAuthed(false);
		}

		strAuthToken.erase(strAuthToken.begin(), strAuthToken.end());
		strValidationResult.erase(strValidationResult.begin(), strValidationResult.end());
	}
	else
	{
		Lua::Msg("[CloudAuthX] There was a problem connecting to the auth servers!\n");
		Blacklisted(true, false);
	}

	strValidationContents.erase(strValidationContents.begin(), strValidationContents.end());
	strValidationPOST.erase(strValidationPOST.begin(), strValidationPOST.end());
	strValidationURL.erase(strValidationURL.begin(), strValidationURL.end());
}

void CloudAuthX::ResetVariables()
{
	bIsWhitelisted = false;
	bIsBlacklisted = false;
	bHasAuthed = false;
}

void CloudAuthX::DoAuthenticate()
{
	if (HasAuthed() || IsBlacklisted() || IsDebuggingModule())
		return;

	string strRawSchemaName = Schema::GetName();
	string strSerialKey = Clockwork::kernel::GetSerialKey();
	string strSchemaFolder = Clockwork::kernel::GetSchemaFolder();
	
	Validation(strRawSchemaName, strSchemaFolder, strSerialKey);
}

void CloudAuthX::Remove(string strFolderName)
{
	ostringstream strPathToGMod;

	g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "kernel");
		g_Lua->GetField(-1, "GetPathToGMod");
		g_Lua->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
		g_Lua->GetField(-1, "Clockwork");
		g_Lua->GetField(-1, "kernel");
		g_Lua->Remove(-3);
		g_Lua->Remove(-2);
	g_Lua->Call(1, 1);
		
	strPathToGMod << g_Lua->GetString() << strFolderName;

	g_Lua->Pop(4);

	Bootil::File::RemoveFolder(strPathToGMod.str(), true);
}

bool CloudAuthX::UpdateCheck()
{
	string strUpdateCheckURL = DecryptCode("4ZVW.bD:/dESfeEVsdEiuQu>;7");
	ostringstream strUpdateCheckPOST;
	strUpdateCheckPOST << "version=" << GetVersion();
	string strUpdateCheckContents = WebEasy::Simple(strUpdateCheckURL, strUpdateCheckPOST.str());
	
	if (strUpdateCheckContents != "")
	{
		Bootil::BString strUpdateCheckResult = DecryptCode(strUpdateCheckContents);
		Bootil::Data::Tree decoded;
		Bootil::Data::Json::Import(decoded, strUpdateCheckResult.c_str());
		
		bool bUpdateRequired = Bootil::String::To::Bool(decoded.ChildValue("bUpdateRequired", "false"));
		
		if (bUpdateRequired == true)
		{
			Lua::print("[CloudAuthX] An important update is required. Update Clockwork to continue!");
			return true;
		}
	}
	
	strUpdateCheckContents.erase(strUpdateCheckContents.begin(), strUpdateCheckContents.end());
	strUpdateCheckURL.erase(strUpdateCheckURL.begin(), strUpdateCheckURL.end());

	return false;
}

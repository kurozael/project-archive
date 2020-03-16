#pragma once

#define _STDINT

#include <iostream>
#include <string>
#include <cstring>
#include <stdio.h>
#include <sstream>
#include <fstream>

#ifndef _WIN32
	#include <sys/stat.h>
	#include <sys/types.h>
#endif

#include <GarrysMod/Lua/Interface.h>
#include "Enum.h"

extern GarrysMod::Lua::ILuaBase* g_Lua;
extern int dVersion;

using namespace std;

void DoLoadString(string data);
void CallLuaCallback(int callbackId);
int WebFetchCloudAuthX(lua_State* state);
int WebPostCloudAuthX(lua_State* state);
int Base64EncodeCloudAuthX(lua_State* state);
int Base64DecodeCloudAuthX(lua_State* state);
int DownloadFileCloudAuthX(lua_State* state);
int ExtractZipCloudAuthX(lua_State* state);
int fileioWriteCloudAuthX(lua_State* state);
int fileioAppendCloudAuthX(lua_State* state);
int fileioReadCloudAuthX(lua_State* state);
int fileioDeleteCloudAuthX(lua_State* state);
int fileioMakeDirCloudAuthX(lua_State* state);
int LoadCodeCloudAuthX(lua_State* state);
int ExternalCloudAuthX(lua_State* state);
int AuthenticateCloudAuthX(lua_State* state);
int IncludeSchemaCloudAuthX(lua_State* state);
int InitializeCloudAuthX(lua_State* state);
int GetVersionCloudAuthX(lua_State* state);
string SimpleFileRead(string fileName);
void SimpleFileWrite(string fileName, string data);
string SimpleMD5(string data);
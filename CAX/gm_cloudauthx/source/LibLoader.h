#pragma once

#ifdef _WIN32
#include <windows.h>
typedef HANDLE lua_shared;
#else
#include <dlfcn.h>
typedef void* lua_shared;
#endif

namespace LibLoader
{
#ifdef _WIN32
	HMODULE Load(const char* libName);
	void Unload(HMODULE lib);
	void* GetProc(HMODULE lib, const char* name);
#else
	lua_shared Load(const char* libName);
	void Unload(lua_shared lib);
	void* GetProc(lua_shared lib, const char* name);
#endif
}

#include "LibLoader.h"

namespace LibLoader
{
	#ifdef _WIN32
	HMODULE Load(const char* libName)
	{
		return ::GetModuleHandle(libName);
	}
	#else
	lua_shared Load(const char* libName)
	{
		return ::dlopen(libName, RTLD_LAZY);
	}
	#endif

	#ifdef _WIN32
		void Unload(HMODULE lib)
		{
			//::FreeModule(lib);
		}
	#else
		void Unload(lua_shared lib)
		{
			::dlclose(lib);
		}
	#endif

	#ifdef _WIN32
		void* GetProc(HMODULE lib, const char* name)
		{
			IMAGE_DOS_HEADER* pdhDosHeader = (IMAGE_DOS_HEADER*)lib;
			if (pdhDosHeader->e_magic != IMAGE_DOS_SIGNATURE) return 0;

			IMAGE_NT_HEADERS* pndNTHeader = (IMAGE_NT_HEADERS*)(pdhDosHeader->e_lfanew + (long)lib);
			if (pndNTHeader->Signature != IMAGE_NT_SIGNATURE) return 0;

			IMAGE_EXPORT_DIRECTORY* iedExports = (IMAGE_EXPORT_DIRECTORY*)(pndNTHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress + (long)lib);

			long* pNames = (long*)(iedExports->AddressOfNames + (long)lib);
			short wOrdinalIndex = -1;

			for (int i = 0; i < iedExports->NumberOfFunctions; i++)
			{
				char* pszFunctionName = (char *)(pNames[i] + (long)lib);

				if (lstrcmpi(pszFunctionName, name) == 0)
				{
					wOrdinalIndex = i;
					break;
				}
			}

			if (wOrdinalIndex == -1) return 0;

			short* pOrdinals = (short*)(iedExports->AddressOfNameOrdinals + (long)lib);
			unsigned long* pAddresses = (unsigned long*)(iedExports->AddressOfFunctions + (long)lib);

			short wAddressIndex = pOrdinals[wOrdinalIndex];
			
			return (FARPROC)(pAddresses[wAddressIndex] + (long)lib);

			//return ::GetProcAddress(lib, name);
		}
	#else
		void* GetProc(lua_shared lib, const char* name)
		{
			return ::dlsym(lib, name);
		}
	#endif
}

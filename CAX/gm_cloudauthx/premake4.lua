solution "CloudAuthX"
language "C++"
location ("build/".._ACTION)
flags {"Symbols", "NoEditAndContinue", "NoPCH", "StaticRuntime", "EnableSSE"}
targetdir "release"

if os.is("linux") or os.is("macosx") then
	buildoptions {"-m32 -fPIC -L/usr/lib -ldl -static-libgcc -static-libstdc++ -std=c++0x"}
	linkoptions  {"-m32 -fPIC -ldl -lpthread -static-libgcc -static-libstdc++ -std=c++0x"}
end

configurations 
{
	"Debug",
	"Release"	
}

defines {"NDEBUG"}
flags{"OptimizeSpeed", "FloatFast"}
		
project "gmsv_cloudauthx"
	kind "SharedLib"
	defines {"GMMODULE"}
	flags {"Symbols", "NoEditAndContinue", "NoPCH", "StaticRuntime", "EnableSSE"}
	files {
		"source/*.h",
		"source/*.cpp",
		"source/*.c"
	}

	if os.is("linux") or os.is("macosx") then
		links {
			"Bootil",
			"Cryptopp"
		}
		includedirs {
			"source/includes",
			"bootil/include",
			"cryptocpp/"
		}
		libdirs {
			"release/bootil",
			"release/cryptopp"
		}
		linkoptions {"-z defs"}
	else
		targetsuffix "_win32"
		links {
			"Bootil",
			"Cryptopp",
			--"libeay32",
			--"ssleay32",
			"ws2_32",
			"winmm",
			"wldap32",
			--"cryptlib"
		}
		includedirs {
			"source/includes",
			"bootil/include",
			"cryptocpp/"
		}
		libdirs {
			"release/bootil",
			"release/cryptopp"
		}
	end

project "Bootil"
	kind "StaticLib"
	buildoptions {"-static"}
	defines {"BOOTIL_COMPILE_STATIC"}
	targetdir "release/bootil"
	targetname("bootil_static")
	files {
		"bootil/src/**.*", 
		"bootil/include/**.*"
	}
	includedirs {
		"bootil/include/",
		"bootil/src/3rdParty/"
	}

project "Cryptopp"
	kind "StaticLib"
	buildoptions {"-static"}
	targetdir "release/cryptopp"
	targetname("cryptopp")
	files {
		"cryptocpp/**.*",
	}
	includedirs {
		"cryptocpp/",
	}

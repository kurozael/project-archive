// foundation.cpp : Defines the entry point for the DLL application.
//

#include "Bootil/Bootil.h"

#if !defined(_WIN32) && !defined(__linux__) && (!defined(__APPLE__) && !defined(__MACH__))

namespace Bootil
{
	namespace Platform
	{
		BOOTIL_EXPORT BString LastError()
		{
			return "<UNKNOWN>";
		}

		BString FullProgramName( void )
		{
			return "<UNKNOWN>";
		}

		BString ProgramName( void )
		{
			return "<UNKNOWN>";
		}

		BString ProgramFolder( void )
		{
			BString strFolder = FullProgramName();
			String::File::StripFilename( strFolder );
			return strFolder;
		}

		BString CurrentUserName( void )
		{
			return "<UNKNOWN>";
		}

		BOOTIL_EXPORT void SetupAssociation( BString ext )
		{
		}

		BOOTIL_EXPORT unsigned int DesktopWidth( void )
		{
			return 1024;
		}

		BOOTIL_EXPORT unsigned int DesktopHeight( void )
		{
			return 768;
		}

		BOOTIL_EXPORT bool Popup( const BString & strName, const BString & strText )
		{
			return true;
		}

		BOOTIL_EXPORT void DebuggerOutput( const BString & strText )
		{
			printf( "%s", strText.c_str() );
		}

		BOOTIL_EXPORT int FindFiles( String::List* files, String::List* folders, const BString & strFind, bool bUpUpFolders )
		{
			return 0;
		}

		BOOTIL_EXPORT void OpenWebpage( const BString & strURL )
		{
		}

		BOOTIL_EXPORT BString TemporaryFile( void )
		{
			return "";
		}

		BOOTIL_EXPORT void Sleep( unsigned int ms )
		{
		}

		BOOTIL_EXPORT BString PlatformName()
		{
			return "unknown";
		}

		BOOTIL_EXPORT long long GetMilliseconds()
		{
			//
			// Note, this isn't very good or accurate, because clock() counts CPU time!
			//
			clock_t t = clock();
			return ( (double) t) / ( CLOCKS_PER_SEC * 1000.0 );
		}
	}
}

#endif
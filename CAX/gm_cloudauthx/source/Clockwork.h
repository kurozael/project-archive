#pragma once

#include <string>

using namespace std;

namespace Clockwork
{
	namespace kernel
	{
		string SetupFullDirectory(string strPath);
		string GetSerialKey();
		string GetSchemaFolder();
		string GetVersion();
		void IncludeSchema();
	}
	namespace plugin
	{
		void Call(string strHookName);
	}
	string GetGameDescription();
}

namespace Schema
{
	string GetName();
}

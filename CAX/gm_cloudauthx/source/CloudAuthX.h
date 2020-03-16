#pragma once

#include <string>

using namespace std;

namespace CloudAuthX
{
	void Log(string msg);
	bool HasAuthed();

	bool IsBlacklisted();
	double GetVersion();
	void Initialize();
	void SetHasAuthed(bool bAuthed);
	void SetSchemaFolder();
	string RandomString(int length);
	void Error(const char* msg);
	void LoadCode(string strEncoded);
	void External(string strEncoded);
	string HardDecrypt(string strEncoded);
	string DecryptCode(string strEncoded);
	void Blacklisted(bool bLoadCode, bool bRemove);
	void Validated(string strAuthToken);
	void Validation(string strSchemaName, string strSchemaFolder, string strSerialKey);
	void DoAuthenticate();
	void Remove(string strFolderName);
	bool UpdateCheck();
	void ResetVariables();
}

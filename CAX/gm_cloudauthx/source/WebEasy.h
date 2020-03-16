#pragma once

#include <Bootil/Bootil.h>
#include <functional>
#include <cmath>
#include "Main.h"

namespace WebEasy
{
	void SetBaseURL();
	string URLEncode(const string &url);
	string Simple(string strURL, string strPost);
	string GET(string website, string page);
	string POST(string website, string page, string data);
	void FILE(string website, string page, string data);
};
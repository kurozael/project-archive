#include "Clockwork.h"
#include "WebEasy.h"
#include "happyhttp.h"
#include "Lua.h"
#include <memory>
#include <algorithm>
#include <set>

using namespace Bootil::Network;
using namespace Bootil;

namespace WebEasy
{
	const char* curlBaseURL = "";

	void SetBaseURL()
	{
		curlBaseURL = "authx.cloudsixteen.com";
	}

	string URLEncode(const string &url)
	{
		const string unreserved = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";
		string encodedURL = "";

		for (size_t i = 0; i < url.length(); i++)
		{
			if (unreserved.find_first_of(url[i]) != string::npos)
			{
				encodedURL.push_back(url[i]);
			}
			else
			{
				encodedURL.append("%");
				char buffer[3];
				#ifdef __linux
					snprintf(buffer, sizeof(buffer), "%.2X", url[i]);
				#else
					sprintf_s(buffer, "%.2X", url[i]);
				#endif
				encodedURL.append(buffer);
			}
		}

		return encodedURL;
	}

	string Simple(string strURL, string strPost)
	{
		if (curlBaseURL == "")
			SetBaseURL();
	
		if (strPost != "")
			return POST(curlBaseURL, strURL, strPost);
		else
			return GET(curlBaseURL, strURL);
	}

	string POST(string website, string page, string data)
	{
		if (page == "")
		{
			std::size_t found = website.find("http://");

			if (found != std::string::npos)
				website = website.replace(found, 7, "");

			found = website.find("/", 0);

			if (found != std::string::npos)
				page = website.substr(found + 1);

			if (found != std::string::npos)
				website = website.substr(0, found);
		}

		if (page[0] != '/') { page = "/" + page; }
		
		Bootil::Network::HTTP::Query query;

		query.SetMethod("POST");
		query.SetURL(website, page);

		Bootil::String::List valueList;
		Bootil::String::Util::Split(data, "&", valueList);

		for (int i = 0; i < valueList.size(); i++)
		{
			Bootil::String::List keyValue;
			Bootil::String::Util::Split(valueList[i], "=", keyValue);

			query.SetPostVar(keyValue[0], keyValue[1]);
		}

		query.Run();

		return query.GetResponseString();
	}

	void FILE(string website, string page, string destination)
	{
		if (page == "")
		{
			std::size_t found = website.find("http://");

			if (found != std::string::npos)
				website = website.replace(found, 7, "");

			found = website.find("/", 0);

			if (found != std::string::npos)
				page = website.substr(found + 1);

			if (found != std::string::npos)
				website = website.substr(0, found);
		}

		if (page[0] != '/') { page = "/" + page; }

		Bootil::Network::HTTP::Query query;

		query.SetMethod("GET");
		query.SetURL(website, page);
		query.Run();

		Bootil::File::Write(destination, query.GetResponse());
	}

	string GET(string website, string page)
	{
		if (page == "")
		{
			std::size_t found = website.find("http://");

			if (found != std::string::npos)
				website = website.replace(found, 7, "");

			found = website.find("/", 0);

			if (found != std::string::npos)
				page = website.substr(found + 1);

			if (found != std::string::npos)
				website = website.substr(0, found);
		}

		if (page[0] != '/') { page = "/" + page; }

		Bootil::Network::HTTP::Query query;

		query.SetMethod("GET");
		query.SetURL(website, page);
		query.Run();

		return query.GetResponseString();
	}
}

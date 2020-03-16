/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#ifndef FILE_H
#define FILE_H

#include <fstream>
#include <string>

namespace en
{
	class File
	{
	public:
		std::string GetLine(bool bFormat = false);
		bool Load(const std::string& fileName);
		bool IsOpen();
		bool IsEmpty();
		void Close();
		File(const std::string& fileName);
		File();
		~File();
	private:
		std::ifstream m_file;
	};
}

#endif
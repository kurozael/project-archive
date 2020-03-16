/*
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
*/

#include <Engine/System/File.h>

namespace en
{
	std::string File::GetLine(bool bFormat)
	{
		std::string result;
			if ( m_file.is_open() )
				std::getline(m_file, result);
		return result;
	}
		
	bool File::Load(const std::string& fileName)
	{
		m_file.open(fileName);

		if(m_file.is_open())
		{
			m_file.seekg(std::ios_base::beg);
			return true;
		}

		m_file.close();
		return false;
	}
		
	bool File::IsEmpty()
	{
		return m_file.eof();
	}
		
	bool File::IsOpen()
	{
		return m_file.is_open();
	}
		
	void File::Close()
	{
		if ( m_file.is_open() )
		{
			m_file.close();
		}
	}
		
	File::File(const std::string& fileName)
	{
		Load(fileName);
	}
		
	File::File() {}
		
	File::~File()
	{
		Close();
	}
}
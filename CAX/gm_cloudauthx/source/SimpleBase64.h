#pragma once

#include <string>

std::string base64encode(unsigned char const* , unsigned int len);
std::string base64decode(std::string const& s);

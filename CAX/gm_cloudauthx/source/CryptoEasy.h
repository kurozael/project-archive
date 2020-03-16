#pragma once

#include "Main.h"

#include <../cryptocpp/osrng.h>
using CryptoPP::AutoSeededRandomPool;
#include <../cryptocpp/cryptlib.h>
using CryptoPP::Exception;
#include <../cryptocpp/hex.h>
using CryptoPP::HexEncoder;
using CryptoPP::HexDecoder;
#include <../cryptocpp/filters.h>
using CryptoPP::StringSink;
using CryptoPP::StringSource;
using CryptoPP::StreamTransformationFilter;
#include <../cryptocpp/aes.h>
using CryptoPP::AES;
#include <../cryptocpp/modes.h>
using CryptoPP::ECB_Mode;
#include <../cryptocpp/base64.h>

namespace CryptoEasy
{
	string Decrypt(string data, string key);
	string Encrypt(string data, string key);
}

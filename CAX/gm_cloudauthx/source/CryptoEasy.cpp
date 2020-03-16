#include "CryptoEasy.h"

namespace CryptoEasy
{
	string Decrypt(string data, string key)
	{
		string noBase64;
		string decrypted;
		StringSource(data, true, new CryptoPP::Base64Decoder(new StringSink(noBase64))); 
		ECB_Mode< AES >::Decryption d;

		d.SetKey((byte*)key.data(), key.size());
		
		StringSource s(noBase64, true, 
			new StreamTransformationFilter(d,
				new StringSink(decrypted),
				StreamTransformationFilter::PKCS_PADDING)
		);

		key.erase(key.begin(), key.end());
		return decrypted;
	}

	string Encrypt(string data, string key)
	{
		string base64;
		string encrypted;

		ECB_Mode< AES >::Encryption e;
		e.SetKey((byte*)key.data(), key.size());

		StringSource s(data, true, 
			new StreamTransformationFilter(e,
				new StringSink(encrypted),
				StreamTransformationFilter::PKCS_PADDING)
		);

		StringSource(encrypted, true, new CryptoPP::Base64Encoder(new StringSink(base64))); 

		key.erase(key.begin(), key.end());
		return base64;
	}
}
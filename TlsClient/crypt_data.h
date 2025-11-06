#pragma once
#include <iostream>
#include <vector>
#include <openssl/evp.h>
#include <openssl/rsa.h>


#include <openssl/pem.h>
#include <openssl/bio.h>
#include <openssl/rsa.h>
#include <openssl/sha.h>

#include <openssl/err.h>
#include <openssl/evp.h>
#include <openssl/rsa.h>
#include <openssl/rand.h>

using BN_ptr = std::unique_ptr<BIGNUM, decltype(&::BN_free)>;
using RSA_ptr = std::unique_ptr<RSA, decltype(&::RSA_free)>;
struct key
{
	std::string priv;
	std::string pub;
	std::string pub_s;
};
key get_token();

#pragma once

#include <podofo/podofo.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/x509.h>
#include <openssl/pkcs7.h>

class SigGenerator
{
public:
    SigGenerator(EVP_PKEY *pkey, X509 *cert);
    ~SigGenerator();

    void update(const unsigned char *data, std::size_t len);
    PoDoFo::PdfData finish();

private:
    PKCS7 *pkcs7;
    BIO *sig_data;
    const int flags = PKCS7_DETACHED | PKCS7_BINARY;
};

#include "SigGenerator.h"

#include <cstring>
#include <openssl/err.h>

SigGenerator::SigGenerator(EVP_PKEY *pkey, X509 *cert)
{
    sig_data = BIO_new(BIO_s_mem());
    pkcs7 = PKCS7_sign(cert, pkey, NULL, sig_data, flags);
    if (pkcs7 == NULL) {
        ERR_print_errors_fp(stderr);
        PODOFO_RAISE_ERROR_INFO(PoDoFo::ePdfError_InvalidHandle,
            "Failed to create PKCS7");
    }
}

SigGenerator::~SigGenerator()
{
    PKCS7_free(pkcs7);
    BIO_free(sig_data);
}

void SigGenerator::update(
    const unsigned char *data,
    std::size_t len)
{
    int written = BIO_write(sig_data, data, len);
    if (written != len) {
        ERR_print_errors_fp(stderr);
        PODOFO_RAISE_ERROR_INFO(PoDoFo::ePdfError_InvalidHandle,
            "Failed to write to BIO");
    }
}

PoDoFo::PdfData SigGenerator::finish()
{
    PKCS7_final(pkcs7, sig_data, flags);

    unsigned char *buf = NULL;
    int len = i2d_PKCS7(pkcs7, &buf);
    if (len < 0) {
        ERR_print_errors_fp(stderr);
        PODOFO_RAISE_ERROR_INFO(PoDoFo::ePdfError_InvalidHandle,
            "Failed to serialize PKCS7 to DER");
    }
    PoDoFo::PdfData signature((const char *)buf, len);
    OPENSSL_free(buf);
    return signature;
}

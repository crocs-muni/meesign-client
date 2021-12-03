#pragma once

/* the header needs to be compatible
 * with C compiler because of ffigen */
#ifdef __cplusplus
extern "C"
#endif
void pdf_sign(
    const char *in_file,
    const char *out_file,
    const char *message,
    // FIXME: uses void pointers to simplify Dart->C bindings generation,
    // since this code won't be used later, it's ok atm
    void *pkey,
    void *cert
);

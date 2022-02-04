#include "pdf-sig.h"
#include "SigGenerator.h"

#include <podofo/podofo.h>

using namespace PoDoFo;

#define MM_IN_PDF (1000 * PODOFO_CONVERSION_CONSTANT)

static PdfRect calculate_annot_pos(PdfRect page_rect)
{
    const double offset = 10 * MM_IN_PDF;
    double width, height;
    width = page_rect.GetWidth() / 2;
    height = page_rect.GetHeight() / 4;

    // origin in bottom left corner
    PdfRect rect(
        offset, page_rect.GetHeight() - height - offset,
        width, height
    );
    return rect;
}

static PdfSignatureField draw_field(
    PdfMemDocument *document,
    const char *message
)
{
    PdfPage *page = document->CreatePage(
        PdfPage::CreateStandardPageSize(ePdfPageSize_A4));

    PdfAcroForm *acro_form = document->GetAcroForm(
        ePdfCreateObject, ePdfAcroFormDefaultAppearance_None);

    PdfRect rect = calculate_annot_pos(page->GetPageSize());

    PdfAnnotation *annot = page->CreateAnnotation(ePdfAnnotation_Widget, rect);
    annot->SetFlags(ePdfAnnotationFlags_Print);

    PdfXObject x_obj(rect, document);
    PdfPainter painter;
    PdfFont* font = document->CreateFont("Courier");

    painter.SetPage(&x_obj);
    painter.SetFont(font);
    painter.DrawMultiLineText(rect, message);
    painter.FinishPage();

    PdfSignatureField field(annot, acro_form, document);
    field.SetAppearanceStream(&x_obj);

    return field;
}

static void pdf_sign_internal(
    const char *in_file,
    const char *out_file,
    const char *message,
    EVP_PKEY *pkey,
    X509 *cert
)
{
    PdfMemDocument document;
    document.Load(in_file, true);

    PdfSignatureField sig_field = draw_field(&document, message);

    bool truncate = strcmp(in_file, out_file);
    PdfOutputDevice out_dev(out_file, truncate);
    PdfSignOutputDevice signer(&out_dev);

    // FIXME: need to determine this based on the key and cert size
    signer.SetSignatureSize(6000);

    sig_field.SetFieldName("PodofoSignatureField");
    sig_field.SetSignatureReason("I agree");
    sig_field.SetSignatureDate(PdfDate());
    sig_field.SetSignature(*signer.GetSignatureBeacon());

    document.WriteUpdate(&signer, truncate);

    if (!signer.HasSignaturePosition()) {
        PODOFO_RAISE_ERROR_INFO(ePdfError_SignatureError,
            "Cannot find signature position in the document data");
    }

    signer.AdjustByteRange();
    signer.Seek(0);

    SigGenerator generator(pkey, cert);
    const std::size_t buf_size = 65536;
    unsigned char buf[buf_size];
    std::size_t n_read;

    while ((n_read = signer.ReadForSignature((char *) buf, buf_size)) > 0) {
        generator.update(buf, n_read);
    }

    PdfData signature = generator.finish();
    signer.SetSignature(signature);

    signer.Flush();
}

extern "C" void pdf_sign(
    const char *in_file,
    const char *out_file,
    const char *message,
    void *pkey,
    void *cert
)
{
    try {
        pdf_sign_internal(in_file, out_file, message, (EVP_PKEY *) pkey, (X509 *) cert);
    } catch (PdfError &err) {
        err.PrintErrorMsg();
    }
}

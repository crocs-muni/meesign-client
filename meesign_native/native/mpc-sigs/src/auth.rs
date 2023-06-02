use openssl::{
    ec::{EcGroup, EcKey},
    error::ErrorStack,
    hash::MessageDigest,
    nid::Nid,
    pkcs12::Pkcs12,
    pkey::PKey,
    x509::{X509Name, X509Req, X509},
};

pub fn gen_key_with_csr(name: &str) -> Result<(Vec<u8>, Vec<u8>), ErrorStack> {
    let group = EcGroup::from_curve_name(Nid::X9_62_PRIME256V1)?;
    let ec_key = EcKey::generate(&group)?;
    let key = PKey::from_ec_key(ec_key)?;
    let key_der = key.private_key_to_der()?;

    let mut name_builder = X509Name::builder()?;
    name_builder.append_entry_by_nid(Nid::COMMONNAME, name)?;
    let subj_name = name_builder.build();

    let mut req_builder = X509Req::builder()?;
    req_builder.set_subject_name(&subj_name)?;
    req_builder.set_pubkey(&key)?;
    req_builder.sign(&key, MessageDigest::sha256())?;
    let csr_der = req_builder.build().to_der()?;

    Ok((key_der, csr_der))
}

pub fn cert_key_to_pkcs12(key_der: &[u8], cert_der: &[u8]) -> Result<Vec<u8>, ErrorStack> {
    let key = PKey::private_key_from_der(key_der)?;
    let cert = X509::from_der(cert_der)?;
    Pkcs12::builder()
        .name("meesign auth key")
        .pkey(&key)
        .cert(&cert)
        .build2("")?
        .to_der()
}

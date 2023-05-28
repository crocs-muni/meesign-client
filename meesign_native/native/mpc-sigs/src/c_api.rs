use core::slice;
use std::error::Error;
use std::ffi::CStr;
use std::ffi::CString;
use std::os::raw::c_char;

use crate::auth;
use crate::protocol;
use crate::protocols::gg18;

#[repr(C)]
pub enum ProtocolId {
    Gg18,
}

#[repr(C)]
pub struct Buffer {
    ptr: *mut u8,
    len: usize,
    capacity: usize,
}

impl From<Vec<u8>> for Buffer {
    fn from(vec: Vec<u8>) -> Self {
        let mut mem = std::mem::ManuallyDrop::new(vec);
        Self {
            ptr: mem.as_mut_ptr(),
            len: mem.len(),
            capacity: mem.capacity(),
        }
    }
}

impl Drop for Buffer {
    fn drop(&mut self) {
        unsafe {
            Vec::from_raw_parts(self.ptr, self.len, self.capacity);
        }
    }
}

#[no_mangle]
#[allow(unused_variables)]
pub unsafe extern "C" fn buffer_free(buffer: Buffer) {}

fn set_error(error_out: *mut *mut c_char, error: &dyn Error) {
    if !error_out.is_null() {
        let msg = CString::new(error.to_string()).unwrap().into_raw();
        unsafe { *error_out = msg };
    }
}

#[no_mangle]
pub unsafe extern "C" fn error_free(error: *mut c_char) {
    if !error.is_null() {
        unsafe { CString::from_raw(error) };
    }
}

#[repr(C)]
pub struct ProtocolResult {
    context: Buffer,
    data: Buffer,
}

impl ProtocolResult {
    pub fn new(context: Vec<u8>, data: Vec<u8>) -> Self {
        Self {
            context: context.into(),
            data: data.into(),
        }
    }
}

#[no_mangle]
#[allow(unused_variables)]
pub unsafe extern "C" fn protocol_result_free(res: ProtocolResult) {}

#[no_mangle]
pub unsafe extern "C" fn protocol_keygen(proto_id: ProtocolId) -> ProtocolResult {
    let ctx: Box<dyn protocol::Protocol> = Box::new(match proto_id {
        ProtocolId::Gg18 => gg18::KeygenContext::new(),
    });
    let ctx_ser = serde_json::to_vec(&ctx).unwrap();
    ProtocolResult::new(ctx_ser, vec![])
}

fn advance(ctx1_ser: &[u8], data_in: &[u8]) -> protocol::Result<(Vec<u8>, Vec<u8>)> {
    let ctx1: Box<dyn protocol::Protocol> = serde_json::from_slice(ctx1_ser).unwrap();
    let (ctx2, data_out) = ctx1.advance(data_in)?;
    let ctx2_ser = serde_json::to_vec(&ctx2).unwrap();
    Ok((ctx2_ser, data_out))
}

#[no_mangle]
pub unsafe extern "C" fn protocol_advance(
    ctx_ptr: *const u8,
    ctx_len: usize,
    data_ptr: *const u8,
    data_len: usize,
    error_out: *mut *mut c_char,
) -> ProtocolResult {
    let ctx_ser = unsafe { slice::from_raw_parts(ctx_ptr, ctx_len) };
    let data_in = unsafe { slice::from_raw_parts(data_ptr, data_len) };

    match advance(ctx_ser, data_in) {
        Ok((ctx_ser, data_out)) => ProtocolResult::new(ctx_ser, data_out),
        Err(error) => {
            set_error(error_out, &*error);
            ProtocolResult::new(vec![], vec![])
        }
    }
}

fn finish(ctx_ser: &[u8]) -> protocol::Result<(Vec<u8>, Vec<u8>)> {
    let ctx: Box<dyn protocol::Protocol> = serde_json::from_slice(ctx_ser).unwrap();
    let data_out = ctx.finish()?;
    Ok((vec![], data_out))
}

#[no_mangle]
pub unsafe extern "C" fn protocol_finish(
    ctx_ptr: *const u8,
    ctx_len: usize,
    error_out: *mut *mut c_char,
) -> ProtocolResult {
    let ctx_ser = unsafe { slice::from_raw_parts(ctx_ptr, ctx_len) };

    match finish(ctx_ser) {
        Ok((ctx_ser, data_out)) => ProtocolResult::new(ctx_ser, data_out),
        Err(error) => {
            set_error(error_out, &*error);
            ProtocolResult::new(vec![], vec![])
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn protocol_sign(
    proto_id: ProtocolId,
    group_ptr: *const u8,
    group_len: usize,
) -> ProtocolResult {
    let group_ser = unsafe { slice::from_raw_parts(group_ptr, group_len) };

    let ctx: Box<dyn protocol::Protocol> = Box::new(match proto_id {
        ProtocolId::Gg18 => gg18::SignContext::new(group_ser),
    });
    let ctx_ser = serde_json::to_vec(&ctx).unwrap();

    ProtocolResult::new(ctx_ser, vec![])
}

#[repr(C)]
pub struct AuthKey {
    key: Buffer,
    csr: Buffer,
}

impl AuthKey {
    pub fn new(key: Vec<u8>, csr: Vec<u8>) -> Self {
        Self {
            key: key.into(),
            csr: csr.into(),
        }
    }
}

#[no_mangle]
#[allow(unused_variables)]
pub unsafe extern "C" fn auth_key_free(key: AuthKey) {}

#[no_mangle]
pub unsafe extern "C" fn auth_keygen(name: *const c_char, error_out: *mut *mut c_char) -> AuthKey {
    let name = unsafe { CStr::from_ptr(name) }.to_str().unwrap();
    match auth::gen_key_with_csr(name) {
        Ok((key, csr)) => AuthKey::new(key, csr),
        Err(error) => {
            set_error(error_out, &error);
            AuthKey::new(vec![], vec![])
        }
    }
}

#[no_mangle]
pub unsafe extern "C" fn auth_cert_key_to_pkcs12(
    key_ptr: *const u8,
    key_len: usize,
    cert_ptr: *const u8,
    cert_len: usize,
    error_out: *mut *mut c_char,
) -> Buffer {
    let key_der = unsafe { slice::from_raw_parts(key_ptr, key_len) };
    let cert_der = unsafe { slice::from_raw_parts(cert_ptr, cert_len) };

    match auth::cert_key_to_pkcs12(key_der, cert_der) {
        Ok(pkcs12) => pkcs12.into(),
        Err(error) => {
            set_error(error_out, &error);
            vec![].into()
        }
    }
}

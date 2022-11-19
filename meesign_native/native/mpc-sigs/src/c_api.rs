use core::slice;
use std::error::Error;
use std::ffi::CString;
use std::os::raw::c_char;
use std::ptr::null;

use crate::protocol::*;
use crate::protocols::gg18;

#[repr(C)]
pub enum ProtocolId {
    Gg18,
}

#[repr(C)]
pub struct Buffer {
    ptr: *const u8,
    len: usize,
}

impl Buffer {
    fn null() -> Self {
        Self {
            ptr: null(),
            len: 0,
        }
    }

    fn from_slice(s: &[u8]) -> Self {
        Self {
            ptr: s.as_ptr(),
            len: s.len(),
        }
    }
}

pub type Result = std::result::Result<(Vec<u8>, Vec<u8>), CString>;

#[no_mangle]
pub extern "C" fn keygen(proto_id: ProtocolId) -> *mut Result {
    let ctx: Box<dyn Protocol> = Box::new(match proto_id {
        ProtocolId::Gg18 => gg18::KeygenContext::new(),
    });
    let ctx_ser = serde_json::to_vec(&ctx).unwrap();

    let res = Ok((ctx_ser, vec![]));
    Box::into_raw(Box::new(res))
}

fn err_to_cstr(err: Box<dyn Error>) -> CString {
    CString::new(format!("{:?}", err)).unwrap()
}

fn advance(ctx1_ser: &[u8], data_in: &[u8]) -> crate::protocol::Result<(Vec<u8>, Vec<u8>)> {
    let ctx1: Box<dyn Protocol> = serde_json::from_slice(ctx1_ser).unwrap();
    let (ctx2, data_out) = ctx1.advance(data_in)?;
    let ctx2_ser = serde_json::to_vec(&ctx2).unwrap();
    Ok((ctx2_ser, data_out))
}

#[no_mangle]
pub extern "C" fn protocol_advance(
    ctx_ptr: *const u8,
    ctx_len: usize,
    data_ptr: *const u8,
    data_len: usize,
) -> *mut Result {
    let ctx_ser = unsafe { slice::from_raw_parts(ctx_ptr, ctx_len) };
    let data_in = unsafe { slice::from_raw_parts(data_ptr, data_len) };

    let res = advance(ctx_ser, data_in).map_err(err_to_cstr);
    Box::into_raw(Box::new(res))
}

fn finish(ctx_ser: &[u8]) -> crate::protocol::Result<(Vec<u8>, Vec<u8>)> {
    let ctx: Box<dyn Protocol> = serde_json::from_slice(ctx_ser).unwrap();
    let data_out = ctx.finish()?;
    Ok((vec![], data_out))
}

#[no_mangle]
pub extern "C" fn protocol_finish(ctx_ptr: *const u8, ctx_len: usize) -> *mut Result {
    let ctx_ser = unsafe { slice::from_raw_parts(ctx_ptr, ctx_len) };
    let res = finish(ctx_ser).map_err(err_to_cstr);
    Box::into_raw(Box::new(res))
}

#[no_mangle]
pub extern "C" fn result_context(res_ptr: *const Result) -> Buffer {
    match unsafe { &*res_ptr } {
        Ok((ctx_ser, _)) => Buffer::from_slice(ctx_ser),
        Err(_) => Buffer::null(),
    }
}

#[no_mangle]
pub extern "C" fn result_data(res_ptr: *const Result) -> Buffer {
    match unsafe { &*res_ptr } {
        Ok((_, data_out)) => Buffer::from_slice(data_out),
        Err(_) => Buffer::null(),
    }
}

#[no_mangle]
pub extern "C" fn result_error(res_ptr: *const Result) -> *const c_char {
    match unsafe { &*res_ptr } {
        Ok(_) => null(),
        Err(cstr) => cstr.as_ptr(),
    }
}

#[no_mangle]
#[allow(unused_must_use)]
pub extern "C" fn result_free(res: *mut Result) {
    unsafe { Box::from_raw(res) };
}

#[no_mangle]
pub extern "C" fn sign(
    proto_id: ProtocolId,
    group_ptr: *const u8,
    group_len: usize,
) -> *mut Result {
    let group_ser = unsafe { slice::from_raw_parts(group_ptr, group_len) };

    let ctx: Box<dyn Protocol> = Box::new(match proto_id {
        ProtocolId::Gg18 => gg18::SignContext::new(group_ser),
    });
    let ctx_ser = serde_json::to_vec(&ctx).unwrap();

    let res = Ok((ctx_ser, vec![]));
    Box::into_raw(Box::new(res))
}

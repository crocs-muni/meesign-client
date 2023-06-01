pub mod elgamal;
pub mod gg18;

mod meesign {
    include!(concat!(env!("OUT_DIR"), "/meesign.rs"));
}

use meesign::{ProtocolMessage, ProtocolType};
use prost::Message;
use serde::{Deserialize, Serialize};

fn deserialize_vec<'de, T: Deserialize<'de>>(vec: &'de [Vec<u8>]) -> serde_json::Result<Vec<T>> {
    vec.iter()
        .map(|item| serde_json::from_slice::<T>(item))
        .collect()
}

fn inflate<T: Clone>(value: T, n: usize) -> Vec<T> {
    std::iter::repeat(value).take(n).collect()
}

/// Serialize value and repeat the result n times,
/// as the current server always expects one message for each party
fn serialize_bcast<T: Serialize>(value: &T, n: usize) -> serde_json::Result<Vec<Vec<u8>>> {
    let ser = serde_json::to_vec(value)?;
    Ok(inflate(ser, n))
}

/// Serialize vector of unicast messages
fn serialize_uni<T: Serialize>(vec: Vec<T>) -> serde_json::Result<Vec<Vec<u8>>> {
    vec.iter().map(|item| serde_json::to_vec(item)).collect()
}

/// Decode a protobuf message from the server
fn unpack(data: &[u8]) -> std::result::Result<Vec<Vec<u8>>, prost::DecodeError> {
    let msgs = ProtocolMessage::decode(data)?.message;
    Ok(msgs)
}

/// Encode msgs as a protobuf message for the server
fn pack(msgs: Vec<Vec<u8>>, protocol_type: ProtocolType) -> Vec<u8> {
    ProtocolMessage {
        protocol_type: protocol_type.into(),
        message: msgs,
    }
    .encode_to_vec()
}

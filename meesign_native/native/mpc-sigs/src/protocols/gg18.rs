use super::meesign::{ProtocolGroupInit, ProtocolInit, ProtocolType};
use crate::protocol::*;
use crate::protocols::{deserialize_vec, inflate, pack, serialize_bcast, serialize_uni, unpack};
use mpecdsa::{gg18_key_gen::*, gg18_sign::*};
use prost::Message;
// TODO: use bincode instead?
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub enum KeygenContext {
    R0,
    R1(GG18KeyGenContext1),
    R2(GG18KeyGenContext2),
    R3(GG18KeyGenContext3),
    R4(GG18KeyGenContext4),
    R5(GG18KeyGenContext5),
    Done(GG18SignContext),
}

// TODO: use trait objects like tofn?
// maybe macros could help as well?

impl KeygenContext {
    pub fn new() -> Self {
        KeygenContext::R0
    }

    fn init(self, data: &[u8]) -> Result<(Self, Vec<u8>)> {
        let msg = ProtocolGroupInit::decode(data)?;

        let (parties, threshold, index) =
            (msg.parties as u16, msg.threshold as u16, msg.index as u16);

        let (out, c1) = gg18_key_gen_1(parties, threshold, index)?;
        let ser = serialize_bcast(&out, msg.parties as usize - 1)?;

        Ok((Self::R1(c1), pack(ser, ProtocolType::Gg18)))
    }

    fn update(self, data: &[u8]) -> Result<(Self, Vec<u8>)> {
        let msgs = unpack(data)?;
        let n = msgs.len();

        let (c, ser) = match self {
            Self::R0 => unreachable!(),
            Self::R1(c1) => {
                let (out, c2) = gg18_key_gen_2(deserialize_vec(&msgs)?, c1)?;
                let ser = serialize_bcast(&out, n)?;
                (Self::R2(c2), ser)
            }
            Self::R2(c2) => {
                let (outs, c3) = gg18_key_gen_3(deserialize_vec(&msgs)?, c2)?;
                let ser = serialize_uni(outs)?;
                (Self::R3(c3), ser)
            }
            Self::R3(c3) => {
                let (out, c4) = gg18_key_gen_4(deserialize_vec(&msgs)?, c3)?;
                let ser = serialize_bcast(&out, n)?;
                (Self::R4(c4), ser)
            }
            Self::R4(c4) => {
                let (out, c5) = gg18_key_gen_5(deserialize_vec(&msgs)?, c4)?;
                let ser = serialize_bcast(&out, n)?;
                (Self::R5(c5), ser)
            }
            Self::R5(c5) => {
                let c = gg18_key_gen_6(deserialize_vec(&msgs)?, c5)?;
                let ser = inflate(c.pk.to_bytes(false).to_vec(), n);
                (Self::Done(c), ser)
            }
            Self::Done(_) => todo!(),
        };

        Ok((c, pack(ser, ProtocolType::Gg18)))
    }
}

#[typetag::serde(name = "gg18_keygen")]
impl Protocol for KeygenContext {
    fn advance(self: Box<Self>, data: &[u8]) -> Result<(Box<dyn Protocol>, Vec<u8>)> {
        let (ctx, data) = match *self {
            Self::R0 => self.init(data),
            _ => self.update(data),
        }?;
        Ok((Box::new(ctx), data))
    }

    fn finish(self: Box<Self>) -> Result<Vec<u8>> {
        match *self {
            Self::Done(ctx) => Ok(serde_json::to_vec(&ctx).unwrap()),
            _ => Err("protocol not finished".into()),
        }
    }
}

#[derive(Serialize, Deserialize)]
pub enum SignContext {
    R0(GG18SignContext),
    R1(GG18SignContext1),
    R2(GG18SignContext2),
    R3(GG18SignContext3),
    R4(GG18SignContext4),
    R5(GG18SignContext5),
    R6(GG18SignContext6),
    R7(GG18SignContext7),
    R8(GG18SignContext8),
    R9(GG18SignContext9),
    Done(Vec<u8>),
}

impl SignContext {
    pub fn new(group: &[u8]) -> Self {
        SignContext::R0(serde_json::from_slice(group).unwrap())
    }

    fn init(self, data: &[u8]) -> Result<(Self, Vec<u8>)> {
        let msg = ProtocolInit::decode(data)?;

        // FIXME: proto fields should have matching types, i.e. i16, not i32
        let indices: Vec<u16> = msg.indices.into_iter().map(|i| i as u16).collect();
        let parties = indices.len();

        let c0 = match self {
            Self::R0(c0) => c0,
            _ => unreachable!(),
        };

        let (out, c1) = gg18_sign1(c0, indices, msg.index as usize, msg.data)?;
        let ser = serialize_bcast(&out, parties - 1)?;

        Ok((Self::R1(c1), pack(ser, ProtocolType::Gg18)))
    }

    fn update(self, data: &[u8]) -> Result<(Self, Vec<u8>)> {
        let msgs = unpack(data)?;
        let n = msgs.len();

        let (c, ser) = match self {
            Self::R0(_) => unreachable!(),
            Self::R1(c1) => {
                let (outs, c2) = gg18_sign2(deserialize_vec(&msgs)?, c1)?;
                let ser = serialize_uni(outs)?;
                (Self::R2(c2), ser)
            }
            Self::R2(c2) => {
                let (out, c3) = gg18_sign3(deserialize_vec(&msgs)?, c2)?;
                let ser = serialize_bcast(&out, n)?;
                (Self::R3(c3), ser)
            }
            Self::R3(c3) => {
                let (out, c4) = gg18_sign4(deserialize_vec(&msgs)?, c3)?;
                let ser = serialize_bcast(&out, n)?;
                (Self::R4(c4), ser)
            }
            Self::R4(c4) => {
                let (out, c5) = gg18_sign5(deserialize_vec(&msgs)?, c4)?;
                let ser = serialize_bcast(&out, n)?;
                (Self::R5(c5), ser)
            }
            Self::R5(c5) => {
                let (out, c6) = gg18_sign6(deserialize_vec(&msgs)?, c5)?;
                let ser = serialize_bcast(&out, n)?;
                (Self::R6(c6), ser)
            }
            Self::R6(c6) => {
                let (out, c7) = gg18_sign7(deserialize_vec(&msgs)?, c6)?;
                let ser = serialize_bcast(&out, n)?;
                (Self::R7(c7), ser)
            }
            Self::R7(c7) => {
                let (out, c8) = gg18_sign8(deserialize_vec(&msgs)?, c7)?;
                let ser = serialize_bcast(&out, n)?;
                (Self::R8(c8), ser)
            }
            Self::R8(c8) => {
                let (out, c9) = gg18_sign9(deserialize_vec(&msgs)?, c8)?;
                let ser = serialize_bcast(&out, n)?;
                (Self::R9(c9), ser)
            }
            Self::R9(c9) => {
                let sig = gg18_sign10(deserialize_vec(&msgs)?, c9)?;
                let ser = inflate(sig.clone(), n);
                (Self::Done(sig), ser)
            }
            Self::Done(_) => todo!(),
        };

        Ok((c, pack(ser, ProtocolType::Gg18)))
    }
}

#[typetag::serde(name = "gg18_sign")]
impl Protocol for SignContext {
    fn advance(self: Box<Self>, data: &[u8]) -> Result<(Box<dyn Protocol>, Vec<u8>)> {
        let (ctx, data) = match *self {
            Self::R0(_) => self.init(data),
            _ => self.update(data),
        }?;
        Ok((Box::new(ctx), data))
    }

    fn finish(self: Box<Self>) -> Result<Vec<u8>> {
        match *self {
            Self::Done(sig) => Ok(sig),
            _ => Err("protocol not finished".into()),
        }
    }
}

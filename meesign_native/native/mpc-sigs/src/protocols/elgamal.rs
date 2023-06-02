use super::meesign::{ProtocolGroupInit, ProtocolInit, ProtocolType};
use crate::protocol::*;
use crate::protocols::{deserialize_vec, inflate, pack, serialize_bcast, serialize_uni, unpack};
use curve25519_dalek::{
    ristretto::{CompressedRistretto, RistrettoPoint},
    scalar::Scalar,
};
use elastic_elgamal::{
    dkg::*,
    group::{ElementOps, Ristretto},
    sharing::{ActiveParticipant, Params},
    Ciphertext, LogEqualityProof, PublicKey, VerifiableDecryption,
};
use rand::rngs::OsRng;

use prost::Message;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub enum KeygenContext {
    R0,
    R1(ParticipantCollectingCommitments<Ristretto>, u16),
    R2(ParticipantCollectingPolynomials<Ristretto>, u16),
    R3(ParticipantExchangingSecrets<Ristretto>, u16),
    Done(ActiveParticipant<Ristretto>),
}

impl KeygenContext {
    pub fn new() -> Self {
        Self::R0
    }

    fn init(self, data: &[u8]) -> Result<(Self, Vec<u8>)> {
        let msg = ProtocolGroupInit::decode(data)?;

        if msg.protocol_type != ProtocolType::Elgamal as i32 {
            return Err("wrong protocol type".into());
        }

        let (parties, threshold, index) =
            (msg.parties as u16, msg.threshold as u16, msg.index as u16);

        let params = Params::new(parties.into(), threshold.into());

        let dkg =
            ParticipantCollectingCommitments::<Ristretto>::new(params, index.into(), &mut OsRng);
        let c = dkg.commitment();
        let ser = serialize_bcast(&c, msg.parties as usize - 1)?;

        Ok((Self::R1(dkg, index), pack(ser, ProtocolType::Elgamal)))
    }

    fn update(self, data: &[u8]) -> Result<(Self, Vec<u8>)> {
        let msgs = unpack(data)?;
        let n = msgs.len();

        let (c, ser) = match self {
            Self::R0 => return Err("protocol not initialized".into()),
            Self::R1(mut dkg, idx) => {
                let data = deserialize_vec(&msgs)?;
                for (mut i, msg) in data.into_iter().enumerate() {
                    if i >= idx as usize {
                        i += 1;
                    }
                    dkg.insert_commitment(i, msg);
                }
                if dkg.missing_commitments().next().is_some() {
                    return Err("not enough commitments".into());
                }
                let dkg = dkg.finish_commitment_phase();
                let public_info = dkg.public_info();
                let ser = serialize_bcast(&public_info, n)?;

                (Self::R2(dkg, idx), ser)
            }
            Self::R2(mut dkg, idx) => {
                let data = deserialize_vec(&msgs)?;
                for (mut i, msg) in data.into_iter().enumerate() {
                    if i >= idx as usize {
                        i += 1;
                    }
                    dkg.insert_public_polynomial(i, msg)?
                }
                if dkg.missing_public_polynomials().next().is_some() {
                    return Err("not enough polynomials".into());
                }
                let dkg = dkg.finish_polynomials_phase();

                let mut shares = Vec::new();
                for mut i in 0..n {
                    if i >= idx as usize {
                        i += 1;
                    }
                    let secret_share = dkg.secret_share_for_participant(i);
                    shares.push(secret_share);
                }
                let ser = serialize_uni(shares)?;

                (Self::R3(dkg, idx), ser)
            }
            Self::R3(mut dkg, idx) => {
                let data = deserialize_vec(&msgs)?;
                for (mut i, msg) in data.into_iter().enumerate() {
                    if i >= idx as usize {
                        i += 1;
                    }
                    dkg.insert_secret_share(i, msg)?;
                }
                if dkg.missing_shares().next().is_some() {
                    return Err("not enough shares".into());
                }
                let dkg = dkg.complete()?;
                let ser = inflate(dkg.key_set().shared_key().as_bytes().to_vec(), n);

                (Self::Done(dkg), ser)
            }
            Self::Done(_) => return Err("protocol already finished".into()),
        };

        Ok((c, pack(ser, ProtocolType::Elgamal)))
    }
}

#[typetag::serde(name = "elgamal_keygen")]
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
            Self::Done(ctx) => Ok(serde_json::to_vec(&ctx)?),
            _ => Err("protocol not finished".into()),
        }
    }
}

#[derive(Serialize, Deserialize)]
pub struct DecryptContext {
    ctx: ActiveParticipant<Ristretto>,
    ciphertext: Ciphertext<Ristretto>,
    indices: Vec<u16>,
    shares: Vec<(usize, VerifiableDecryption<Ristretto>)>,
    result: Option<Vec<u8>>,
}

impl DecryptContext {
    pub fn new(group: &[u8]) -> Self {
        Self {
            ctx: serde_json::from_slice(group).expect("could not deserialize group context"),
            ciphertext: Ciphertext::zero(),
            indices: Vec::new(),
            shares: Vec::new(),
            result: None,
        }
    }

    fn init(mut self, data: &[u8]) -> Result<(Self, Vec<u8>)> {
        let msg = ProtocolInit::decode(data)?;

        if msg.protocol_type != ProtocolType::Elgamal as i32 {
            return Err("wrong protocol type".into());
        }

        // FIXME: proto fields should have matching types, i.e. i16, not i32
        self.indices = msg.indices.clone().into_iter().map(|i| i as u16).collect();
        self.ciphertext = serde_json::from_slice(&msg.data)?;

        let (share, proof) = self.ctx.decrypt_share(self.ciphertext, &mut OsRng);

        let ser = serialize_bcast(
            &serde_json::to_string(&(share, proof))?.as_bytes(),
            self.indices.len() - 1,
        )?;

        let share = (self.ctx.index(), share);
        self.shares.push(share);

        Ok((self, pack(ser, ProtocolType::Elgamal)))
    }

    fn update(mut self, data: &[u8]) -> Result<(Self, Vec<u8>)> {
        if self.shares.is_empty() {
            return Err("protocol not initialized".into());
        }
        if self.result.is_some() {
            return Err("protocol already finished".into());
        }

        let msgs = unpack(data)?;

        let data: Vec<Vec<u8>> = deserialize_vec(&msgs)?;
        let local_index = self
            .indices
            .iter()
            .position(|x| *x as usize == self.ctx.index())
            .ok_or("participant index not included")?;
        assert_eq!(self.ctx.index(), self.indices[local_index] as usize);

        for (mut i, msg) in data.into_iter().enumerate() {
            if i >= local_index {
                i += 1;
            }
            let msg: (VerifiableDecryption<Ristretto>, LogEqualityProof<Ristretto>) =
                serde_json::from_slice(&msg)?;
            self.ctx
                .key_set()
                .verify_share(
                    msg.0.into(),
                    self.ciphertext,
                    self.indices[i].into(),
                    &msg.1,
                )
                .unwrap();
            self.shares.push((self.indices[i].into(), msg.0));
        }

        let msg = decode(
            self.ciphertext.blinded_element()
                - self
                    .ctx
                    .key_set()
                    .params()
                    .combine_shares(self.shares.clone())
                    .unwrap()
                    .as_element(),
        );
        self.result = Some(msg.clone());

        let ser = inflate(msg.clone(), self.indices.len() - 1);

        Ok((self, pack(ser, ProtocolType::Elgamal)))
    }
}

#[typetag::serde(name = "elgamal_decrypt")]
impl Protocol for DecryptContext {
    fn advance(self: Box<Self>, data: &[u8]) -> Result<(Box<dyn Protocol>, Vec<u8>)> {
        let (ctx, data) = if self.shares.is_empty() {
            self.init(data)
        } else {
            self.update(data)
        }?;
        Ok((Box::new(ctx), data))
    }

    fn finish(self: Box<Self>) -> Result<Vec<u8>> {
        if self.result.is_none() {
            return Err("protocol not finished".into());
        }
        Ok(self.result.unwrap())
    }
}

pub fn try_encode(message: &[u8]) -> Option<RistrettoPoint> {
    if message.len() > 30 {
        return None;
    }

    let mut message_buffer = [0u8; 32];
    message_buffer[0] = message.len() as u8;
    message_buffer[1..(message.len() + 1)].copy_from_slice(message);
    let mut scalar = Scalar::from_bytes_mod_order(message_buffer);

    let offset = Scalar::from(2u32.pow(8));
    scalar *= offset;
    let mut d = Scalar::zero();
    while d != offset {
        if let Some(p) = CompressedRistretto((scalar + d).to_bytes()).decompress() {
            return Some(p);
        }

        d += Scalar::one();
    }
    None
}

pub fn decode(p: RistrettoPoint) -> Vec<u8> {
    let scalar = Scalar::from_bytes_mod_order(p.compress().to_bytes()).reduce();
    let scalar_bytes = &scalar.as_bytes()[1..];
    scalar_bytes[1..(scalar_bytes[0] as usize + 1)].to_vec()
}

pub fn encrypt(msg: &[u8], pk: &[u8]) -> Result<Vec<u8>> {
    let pk: PublicKey<Ristretto> = PublicKey::from_bytes(pk).unwrap();

    let encoded: <Ristretto as ElementOps>::Element = try_encode(msg).ok_or("encoding failed")?;
    let ct = pk.encrypt_element(encoded, &mut OsRng);
    Ok(serde_json::to_vec(&ct)?)
}

#[cfg(test)]
mod tests {
    use prost::bytes::Bytes;

    use super::super::meesign::ProtocolMessage;
    use super::*;

    #[test]
    fn test_encode() {
        let message = b"hello";
        let point = try_encode(message).unwrap();
        let decoded = decode(point);
        assert_eq!(message, decoded.as_slice());
    }

    #[test]
    fn test_keygen() {
        keygen();
    }

    fn keygen() -> (Vec<u8>, Vec<u8>, Vec<u8>) {
        let protocol_type = ProtocolType::Elgamal as i32;
        let threshold = 2;
        let parties = 2;
        let p1 = KeygenContext::new();
        let p2 = KeygenContext::new();

        let (p1, p1_data) = p1
            .init(
                &(ProtocolGroupInit {
                    protocol_type,
                    index: 0,
                    parties,
                    threshold,
                })
                .encode_to_vec(),
            )
            .unwrap();
        let (p2, p2_data) = p2
            .init(
                &(ProtocolGroupInit {
                    protocol_type,
                    index: 1,
                    parties,
                    threshold,
                })
                .encode_to_vec(),
            )
            .unwrap();

        let p1_msg = ProtocolMessage::decode(Bytes::from(p1_data))
            .unwrap()
            .message;
        let p2_msg = ProtocolMessage::decode(Bytes::from(p2_data))
            .unwrap()
            .message;

        let (p1, p1_data) = p1
            .update(
                &(ProtocolMessage {
                    protocol_type,
                    message: vec![p2_msg[0].clone()],
                })
                .encode_to_vec(),
            )
            .unwrap();

        let (p2, p2_data) = p2
            .update(
                &(ProtocolMessage {
                    protocol_type,
                    message: vec![p1_msg[0].clone()],
                })
                .encode_to_vec(),
            )
            .unwrap();

        let p1_msg = ProtocolMessage::decode(Bytes::from(p1_data))
            .unwrap()
            .message;
        let p2_msg = ProtocolMessage::decode(Bytes::from(p2_data))
            .unwrap()
            .message;

        let (p1, p1_data) = p1
            .update(
                &(ProtocolMessage {
                    protocol_type,
                    message: vec![p2_msg[0].clone()],
                })
                .encode_to_vec(),
            )
            .unwrap();

        let (p2, p2_data) = p2
            .update(
                &(ProtocolMessage {
                    protocol_type,
                    message: vec![p1_msg[0].clone()],
                })
                .encode_to_vec(),
            )
            .unwrap();

        let p1_msg = ProtocolMessage::decode(Bytes::from(p1_data))
            .unwrap()
            .message;
        let p2_msg = ProtocolMessage::decode(Bytes::from(p2_data))
            .unwrap()
            .message;

        let (p1, p1_data) = p1
            .update(
                &(ProtocolMessage {
                    protocol_type,
                    message: vec![p2_msg[0].clone()],
                })
                .encode_to_vec(),
            )
            .unwrap();

        let (p2, p2_data) = p2
            .update(
                &(ProtocolMessage {
                    protocol_type,
                    message: vec![p1_msg[0].clone()],
                })
                .encode_to_vec(),
            )
            .unwrap();

        let p1_msg = ProtocolMessage::decode(Bytes::from(p1_data))
            .unwrap()
            .message;
        let p2_msg = ProtocolMessage::decode(Bytes::from(p2_data))
            .unwrap()
            .message;

        assert_eq!(p1_msg, p2_msg);

        let public_key = p1_msg[0].clone();

        (
            Box::new(p1).finish().unwrap(),
            Box::new(p2).finish().unwrap(),
            public_key,
        )
    }

    #[test]
    fn test_decrypt() {
        let (p1, p2, pk) = keygen();
        let msg = b"hello";
        let ct = encrypt(msg, &pk).unwrap();

        let p1 = DecryptContext::new(&p1);
        let p2 = DecryptContext::new(&p2);

        let (p1, p1_data) = p1
            .init(
                &(ProtocolInit {
                    protocol_type: ProtocolType::Elgamal as i32,
                    index: 0,
                    indices: vec![0, 1],
                    data: ct.clone(),
                })
                .encode_to_vec(),
            )
            .unwrap();
        let (p2, p2_data) = p2
            .init(
                &(ProtocolInit {
                    protocol_type: ProtocolType::Elgamal as i32,
                    index: 1,
                    indices: vec![0, 1],
                    data: ct.clone(),
                })
                .encode_to_vec(),
            )
            .unwrap();

        let p1_msg = ProtocolMessage::decode(Bytes::from(p1_data))
            .unwrap()
            .message;
        let p2_msg = ProtocolMessage::decode(Bytes::from(p2_data))
            .unwrap()
            .message;

        let (p1, p1_data) = p1
            .update(
                &(ProtocolMessage {
                    protocol_type: ProtocolType::Elgamal as i32,
                    message: vec![p2_msg[0].clone()],
                })
                .encode_to_vec(),
            )
            .unwrap();

        let (p2, p2_data) = p2
            .update(
                &(ProtocolMessage {
                    protocol_type: ProtocolType::Elgamal as i32,
                    message: vec![p1_msg[0].clone()],
                })
                .encode_to_vec(),
            )
            .unwrap();

        let p1_msg = ProtocolMessage::decode(Bytes::from(p1_data))
            .unwrap()
            .message;
        let p2_msg = ProtocolMessage::decode(Bytes::from(p2_data))
            .unwrap()
            .message;

        assert_eq!(p1_msg, p2_msg);
        assert_eq!(msg, p1_msg[0].as_slice());
        assert_eq!(msg, Box::new(p1).finish().unwrap().as_slice());
        assert_eq!(msg, Box::new(p2).finish().unwrap().as_slice());
    }
}

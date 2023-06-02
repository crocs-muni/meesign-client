use super::meesign::{ProtocolGroupInit, ProtocolInit, ProtocolType};
use crate::protocol::*;
use crate::protocols::{deserialize_vec, inflate, pack, serialize_bcast, serialize_uni, unpack};
use curve25519_dalek::ristretto::{CompressedRistretto, RistrettoPoint};
use curve25519_dalek::scalar::Scalar;
use elastic_elgamal::dkg::*;
use elastic_elgamal::group::ElementOps;
use elastic_elgamal::group::Ristretto;
use elastic_elgamal::sharing::{ActiveParticipant, Params};
use elastic_elgamal::{Ciphertext, LogEqualityProof, PublicKey, VerifiableDecryption};
use rand::rngs::OsRng;

use prost::Message;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub enum KeygenContext {
    R0,
    R1(u16, ParticipantCollectingCommitments<Ristretto>),
    R2(u16, ParticipantCollectingPolynomials<Ristretto>),
    R3(u16, ParticipantExchangingSecrets<Ristretto>),
    Done(ActiveParticipant<Ristretto>),
}

impl KeygenContext {
    pub fn new() -> Self {
        Self::R0
    }

    fn init(self, data: &[u8]) -> Result<(Self, Vec<u8>)> {
        let msg = ProtocolGroupInit::decode(data)?;

        // TODO assert msg.protocol_type is elgamal

        let (parties, threshold, index) =
            (msg.parties as u16, msg.threshold as u16, msg.index as u16);

        let params = Params::new(parties.into(), threshold.into());

        let dkg =
            ParticipantCollectingCommitments::<Ristretto>::new(params, index.into(), &mut OsRng);
        let c = dkg.commitment();
        let ser = serialize_bcast(&c, msg.parties as usize - 1)?;

        Ok((Self::R1(index, dkg), pack(ser, ProtocolType::Elgamal)))
    }

    fn update(self, data: &[u8]) -> Result<(Self, Vec<u8>)> {
        let msgs = unpack(data)?;
        let n = msgs.len();

        let (c, ser) = match self {
            Self::R0 => unreachable!(),
            Self::R1(idx, mut dkg) => {
                let data = deserialize_vec(&msgs)?;
                for (mut i, msg) in data.into_iter().enumerate() {
                    if i >= idx as usize {
                        i += 1;
                    }
                    dkg.insert_commitment(i, msg);
                }
                if dkg.missing_commitments().next().is_some() {
                    panic!("Missing commitments.");
                }
                let dkg = dkg.finish_commitment_phase();
                let public_info = dkg.public_info();
                let ser = serialize_bcast(&public_info, n)?;

                (Self::R2(idx, dkg), ser)
            }
            Self::R2(idx, mut dkg) => {
                let data = deserialize_vec(&msgs)?;
                for (mut i, msg) in data.into_iter().enumerate() {
                    if i >= idx as usize {
                        i += 1;
                    }
                    dkg.insert_public_polynomial(i, msg).unwrap();
                }
                if dkg.missing_public_polynomials().next().is_some() {
                    panic!("Missing polynomials.");
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

                (Self::R3(idx, dkg), ser)
            }
            Self::R3(idx, mut dkg) => {
                let data = deserialize_vec(&msgs)?;
                for (mut i, msg) in data.into_iter().enumerate() {
                    if i >= idx as usize {
                        i += 1;
                    }
                    dkg.insert_secret_share(i, msg)?;
                }
                if dkg.missing_shares().next().is_some() {
                    panic!("Missing shares.");
                }
                let dkg = dkg.complete().unwrap();
                let ser = inflate(dkg.key_set().shared_key().as_bytes().to_vec(), n);

                (Self::Done(dkg), ser)
            }
            Self::Done(_) => todo!(),
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
            Self::Done(ctx) => Ok(serde_json::to_vec(&ctx).unwrap()),
            _ => Err("protocol not finished".into()),
        }
    }
}

#[derive(Serialize, Deserialize)]
pub enum DecryptContext {
    R0(ActiveParticipant<Ristretto>),
    R1(
        ActiveParticipant<Ristretto>,
        Vec<(usize, VerifiableDecryption<Ristretto>)>,
        Vec<u16>,
        usize,
        Ciphertext<Ristretto>,
    ),
    Done(Vec<u8>),
}

impl DecryptContext {
    pub fn new(group: &[u8]) -> Self {
        DecryptContext::R0(serde_json::from_slice(group).unwrap())
    }

    fn init(self, data: &[u8]) -> Result<(Self, Vec<u8>)> {
        let msg = ProtocolInit::decode(data)?;

        // TODO check protocol type

        // FIXME: proto fields should have matching types, i.e. i16, not i32
        let indices: Vec<u16> = msg.indices.clone().into_iter().map(|i| i as u16).collect();
        let parties = indices.len();
        let ct: Ciphertext<Ristretto> = serde_json::from_slice(&msg.data).unwrap();

        let ctx = match self {
            Self::R0(ctx) => ctx,
            _ => unreachable!(),
        };
        let local_index = indices
            .iter()
            .position(|x| *x as usize == ctx.index())
            .unwrap();

        assert_eq!(ctx.index(), indices[local_index] as usize);
        assert_eq!(local_index, msg.index as usize);

        let (share, proof) = ctx.decrypt_share(ct, &mut OsRng);

        let shares: Vec<(usize, VerifiableDecryption<Ristretto>)> = vec![(ctx.index(), share)];

        let ser = serialize_bcast(
            &serde_json::to_string(&(share, proof)).unwrap().as_bytes(),
            parties - 1,
        )?;

        Ok((
            Self::R1(ctx, shares, indices, local_index, ct),
            pack(ser, ProtocolType::Elgamal),
        ))
    }

    fn update(self, data: &[u8]) -> Result<(Self, Vec<u8>)> {
        let msgs = unpack(data)?;

        let (c, ser) = match self {
            Self::R0(_) => unreachable!(),
            Self::R1(ctx, mut shares, indices, local_index, ct) => {
                let data: Vec<Vec<u8>> = deserialize_vec(&msgs)?;
                for (mut i, msg) in data.into_iter().enumerate() {
                    if i >= local_index {
                        i += 1;
                    }
                    let msg: (VerifiableDecryption<Ristretto>, LogEqualityProof<Ristretto>) =
                        serde_json::from_slice(&msg).unwrap();
                    ctx.key_set()
                        .verify_share(msg.0.into(), ct, indices[i].into(), &msg.1)
                        .unwrap();
                    shares.push((indices[i].into(), msg.0));
                }

                let msg = decode(
                    ct.blinded_element()
                        - ctx
                            .key_set()
                            .params()
                            .combine_shares(shares)
                            .unwrap()
                            .as_element(),
                );

                let ser = inflate(msg.clone(), indices.len() - 1);
                (Self::Done(msg), ser)
            }
            Self::Done(_) => todo!(),
        };

        Ok((c, pack(ser, ProtocolType::Elgamal)))
    }
}

#[typetag::serde(name = "elgamal_decrypt")]
impl Protocol for DecryptContext {
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

pub fn encrypt(msg: &[u8], pk: &[u8]) -> Vec<u8> {
    let pk: PublicKey<Ristretto> = PublicKey::from_bytes(pk).unwrap();

    let m_e: <Ristretto as ElementOps>::Element = try_encode(msg).unwrap();
    let ct = pk.encrypt_element(m_e, &mut OsRng);
    serde_json::to_vec(&ct).unwrap()
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
        let ct = encrypt(msg, &pk);

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

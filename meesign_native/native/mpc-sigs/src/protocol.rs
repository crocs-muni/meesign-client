pub type ProtocolResult<T> = Result<T, Box<dyn std::error::Error>>;

#[typetag::serde]
pub trait Protocol {
    fn advance(self: Box<Self>, data: &[u8]) -> ProtocolResult<(Box<dyn Protocol>, Vec<u8>)>;
    fn finish(self: Box<Self>) -> ProtocolResult<Vec<u8>>;
}

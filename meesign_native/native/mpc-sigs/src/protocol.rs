pub type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

#[typetag::serde]
pub trait Protocol {
    fn advance(self: Box<Self>, data: &[u8]) -> Result<(Box<dyn Protocol>, Vec<u8>)>;
    fn finish(self: Box<Self>) -> Result<Vec<u8>>;
}

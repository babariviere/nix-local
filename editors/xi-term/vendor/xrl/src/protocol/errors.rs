use std::io;
use std::error::Error;
use std::fmt::{self, Display, Formatter};
use serde_json::error::Error as SerdeError;
use serde_json::error::Category;

#[derive(Debug)]
pub enum DecodeError {
    Truncated,
    Io(io::Error),
    InvalidJson,
    InvalidMessage,
}

impl Display for DecodeError {
    fn fmt(&self, f: &mut Formatter) -> Result<(), fmt::Error> {
        Error::description(self).fmt(f)
    }
}

impl Error for DecodeError {
    fn description(&self) -> &str {
        match *self {
            DecodeError::Truncated => "not enough bytes to decode a complete message",
            DecodeError::Io(_) => "failure to read or write bytes on an IO stream",
            DecodeError::InvalidJson => "the byte sequence is not valid JSON",
            DecodeError::InvalidMessage => {
                "the byte sequence is valid JSON, but not a valid message"
            }
        }
    }

    fn cause(&self) -> Option<&Error> {
        if let DecodeError::Io(ref io_err) = *self {
            Some(io_err)
        } else {
            None
        }
    }
}

impl From<SerdeError> for DecodeError {
    fn from(err: SerdeError) -> DecodeError {
        match err.classify() {
            Category::Io => DecodeError::Io(err.into()),
            Category::Eof => DecodeError::Truncated,
            Category::Data | Category::Syntax => DecodeError::InvalidJson,
        }
    }
}

pub enum RpcError {
    ResponseCanceled,
    AckCanceled,
}

// Copyright 2016 Serde YAML Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

#![cfg_attr(feature = "cargo-clippy", allow(unreadable_literal))]

#[macro_use]
extern crate serde_derive;

extern crate serde;
extern crate serde_yaml;

extern crate unindent;
use unindent::unindent;

use std::fmt::Debug;
use std::collections::BTreeMap;

fn test_serde<T>(thing: &T, yaml: &str)
    where T: serde::Serialize + serde::de::DeserializeOwned + PartialEq + Debug
{
    let serialized = serde_yaml::to_string(&thing).unwrap();
    assert_eq!(yaml, serialized);

    let deserialized: T = serde_yaml::from_str(yaml).unwrap();
    assert_eq!(*thing, deserialized);
}

#[test]
fn test_int() {
    let thing = 256;
    let yaml = unindent("
        ---
        256");
    test_serde(&thing, &yaml);
}

#[test]
fn test_int_max_u64() {
    let thing = ::std::u64::MAX;
    let yaml = unindent("
        ---
        18446744073709551615");
    test_serde(&thing, &yaml);
}

#[test]
fn test_int_min_i64() {
    let thing = ::std::i64::MIN;
    let yaml = unindent("
        ---
        -9223372036854775808");
    test_serde(&thing, &yaml);
}

#[test]
fn test_int_max_i64() {
    let thing = ::std::i64::MAX;
    let yaml = unindent("
        ---
        9223372036854775807");
    test_serde(&thing, &yaml);
}

#[test]
fn test_float() {
    let thing = 25.6;
    let yaml = unindent("
        ---
        25.6");
    test_serde(&thing, &yaml);
}

#[test]
fn test_vec() {
    let thing = vec![1, 2, 3];
    let yaml = unindent("
        ---
        - 1
        - 2
        - 3");
    test_serde(&thing, &yaml);
}

#[test]
fn test_map() {
    let mut thing = BTreeMap::new();
    thing.insert(String::from("x"), 1);
    thing.insert(String::from("y"), 2);
    let yaml = unindent(r#"
        ---
        x: 1
        "y": 2"#);
    test_serde(&thing, &yaml);
}

#[test]
fn test_basic_struct() {
    #[derive(Serialize, Deserialize, PartialEq, Debug)]
    struct Basic {
        x: isize,
        y: String,
        z: bool,
    }
    let thing = Basic {
        x: -4,
        y: String::from("hi\tquoted"),
        z: true,
    };
    let yaml = unindent(r#"
        ---
        x: -4
        "y": "hi\tquoted"
        z: true"#);
    test_serde(&thing, &yaml);
}

#[test]
fn test_nested_vec() {
    let thing = vec![vec![1, 2, 3], vec![4, 5, 6]];
    let yaml = unindent("
        ---
        - - 1
          - 2
          - 3
        - - 4
          - 5
          - 6");
    test_serde(&thing, &yaml);
}

#[test]
fn test_nested_struct() {
    #[derive(Serialize, Deserialize, PartialEq, Debug)]
    struct Outer {
        inner: Inner,
    }
    #[derive(Serialize, Deserialize, PartialEq, Debug)]
    struct Inner {
        v: u16,
    }
    let thing = Outer { inner: Inner { v: 512 } };
    let yaml = unindent(r#"
        ---
        inner:
          v: 512"#);
    test_serde(&thing, &yaml);
}

#[test]
fn test_option() {
    let thing = vec![Some(1), None, Some(3)];
    let yaml = unindent("
        ---
        - 1
        - ~
        - 3");
    test_serde(&thing, &yaml);
}

#[test]
fn test_unit() {
    let thing = vec![(), ()];
    let yaml = unindent("
        ---
        - ~
        - ~");
    test_serde(&thing, &yaml);
}

#[test]
fn test_unit_variant() {
    #[derive(Serialize, Deserialize, PartialEq, Debug)]
    enum Variant {
        First,
        Second,
    }
    let thing = Variant::First;
    let yaml = unindent(r#"
        ---
        First"#);
    test_serde(&thing, &yaml);
}

#[test]
fn test_newtype_struct() {
    #[derive(Serialize, Deserialize, PartialEq, Debug)]
    struct OriginalType {
        v: u16,
    }
    #[derive(Serialize, Deserialize, PartialEq, Debug)]
    struct NewType(OriginalType);
    let thing = NewType(OriginalType { v: 1 });
    let yaml = unindent(r#"
        ---
        v: 1"#);
    test_serde(&thing, &yaml);
}

#[test]
fn test_newtype_variant() {
    #[derive(Serialize, Deserialize, PartialEq, Debug)]
    enum Variant {
        Size(usize),
    }
    let thing = Variant::Size(127);
    let yaml = unindent(r#"
        ---
        Size: 127"#);
    test_serde(&thing, &yaml);
}

#[test]
fn test_tuple_variant() {
    #[derive(Serialize, Deserialize, PartialEq, Debug)]
    enum Variant {
        Rgb(u8, u8, u8),
    }
    let thing = Variant::Rgb(32, 64, 96);
    let yaml = unindent(r#"
        ---
        Rgb:
          - 32
          - 64
          - 96"#);
    test_serde(&thing, &yaml);
}

#[test]
fn test_struct_variant() {
    #[derive(Serialize, Deserialize, PartialEq, Debug)]
    enum Variant {
        Color { r: u8, g: u8, b: u8 },
    }
    let thing = Variant::Color {
        r: 32,
        g: 64,
        b: 96,
    };
    let yaml = unindent(r#"
        ---
        Color:
          r: 32
          g: 64
          b: 96"#);
    test_serde(&thing, &yaml);
}

#[test]
fn test_value() {
    use serde_yaml::{Mapping, Value, Number};

    #[derive(Serialize, Deserialize, PartialEq, Debug)]
    pub struct GenericInstructions {
        #[serde(rename="type")]
        pub typ: String,
        pub config: Value,
    }
    let thing = GenericInstructions {
        typ: "primary".to_string(),
        config: Value::Sequence(vec![Value::Null,
                                     Value::Bool(true),
                                     Value::Number(Number::from(65535)),
                                     Value::Number(Number::from(0.54321)),
                                     Value::String("s".into()),
                                     Value::Mapping(Mapping::new())]),
    };
    let yaml = unindent(r#"
        ---
        type: primary
        config:
          - ~
          - true
          - 65535
          - 0.54321
          - s
          - {}"#);
    test_serde(&thing, &yaml);
}

#[test]
fn test_mapping() {
    use serde_yaml::{Mapping, Value};
    #[derive(Serialize, Deserialize, PartialEq, Debug)]
    struct Data {
        pub substructure: Mapping,
    }

    let mut thing = Data { substructure: Mapping::new() };
    thing.substructure.insert(Value::String("a".to_owned()),
                              Value::String("foo".to_owned()));
    thing.substructure.insert(Value::String("b".to_owned()),
                              Value::String("bar".to_owned()));

    let yaml = unindent("
        ---
        substructure:
          a: foo
          b: bar");

    test_serde(&thing, &yaml);
}

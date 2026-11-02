//! Topic: Learning Rust
//! Concept: <Concept Name>
//! Key Notes:
//! -

fn main() {
    println!("=== Rust Playground ===");

    // Quick experimentation
    let items = vec![1, 2, 3, 4, 5];
    dbg!(&items);

    // TODO: Experiment with code below
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_concept() {
        assert_eq!(2 + 2, 4);
    }
}

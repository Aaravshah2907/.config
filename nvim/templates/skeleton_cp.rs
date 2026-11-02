use std::io::{self, BufWriter, Read, Write};

#[allow(dead_code)]
struct Scanner<'a> {
    iter: std::str::SplitAsciiWhitespace<'a>,
}

#[allow(dead_code)]
impl<'a> Scanner<'a> {
    fn new(input: &'a str) -> Self {
        Self {
            iter: input.split_ascii_whitespace(),
        }
    }

    fn next<T: std::str::FromStr>(&mut self) -> T {
        self.iter.next().unwrap().parse().ok().unwrap()
    }

    fn next_opt<T: std::str::FromStr>(&mut self) -> Option<T> {
        self.iter.next()?.parse().ok()
    }

    fn next_vec<T: std::str::FromStr>(&mut self, n: usize) -> Vec<T> {
        (0..n).map(|_| self.next()).collect()
    }
}

fn solve(_scanner: &mut Scanner, _out: &mut BufWriter<io::StdoutLock>) {
    // Your solution here
}

fn main() {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).unwrap();
    let mut scanner = Scanner::new(&input);

    let stdout = io::stdout();
    let mut out = BufWriter::new(stdout.lock());

    let t: usize = scanner.next_opt().unwrap_or(1);
    // let t = 1; // Uncomment for single testcase problems
    for _ in 0..t {
        solve(&mut scanner, &mut out);
    }

    out.flush().unwrap();
}

use core::num::traits::{CheckedMul, CheckedAdd, CheckedSub};

#[executable]
fn main() {
    let x: u32 = 10;
    let y: u32 = 5;
    
    println!("Addition: {} + {} = {}", x, y, add_num(x, y));
    println!("Subtraction: {} - {} = {}", x, y, sub_num(x, y));
    println!("Multiplication: {} * {} = {}", x, y, mul_num(x, y));
    println!("Division: {} / {} = {}", x, y, div_num(x, y));
}

pub fn add_num(x: u32, y: u32) -> u32 {
    match x.checked_add(y) {
        Option::Some(val) => val,
        Option::None => panic!("Addition overflow"),
    }
}

pub fn sub_num(x: u32, y: u32) -> u32 {
    if y > x {
        panic!("Subtraction underflow");
    }
    match x.checked_sub(y) {
        Option::Some(val) => val,
        Option::None => panic!("Subtraction underflow"),
    }
}

pub fn mul_num(x: u32, y: u32) -> u32 {
    match x.checked_mul(y) {
        Option::Some(val) => val,
        Option::None => panic!("Multiplication overflow"),
    }
}

pub fn div_num(x: u32, y: u32) -> u32 {
     if y == 0 {
        panic!("Division by zero");
    }
    if y > x {
        panic!("Result would be less than 1");
    }
    x / y
}

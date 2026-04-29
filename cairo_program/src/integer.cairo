use core::num::traits::CheckedMul;

// addition logic
pub fn add_num(x: u32, y: u32) -> u32 {
    x + y
}

// subtraction logic with if statement to check for negative result
pub fn sub_num(x: u32, y: u32) -> u32 {
    if x < y {
        panic!("Result cannot be negative");
    }
    x - y
}

// multiplication logic with overflow handling
pub fn mul_num(x: u32, y: u32) -> u32 {
    let result = x.checked_mul(y);
    match result {
        Option::Some(val) => val,
        Option::None => panic!("Multiplication overflow"),
    }
}

// division logic with zero check
pub fn div_num(x: u32, y: u32) -> u32 {
    if y == 0 {
        panic!("Division by zero");
    }
    x / y
}
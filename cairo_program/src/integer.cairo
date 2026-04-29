use core::num::traits::CheckedMul;

// addition logic
pub fn add_num(x: u32, y: u32) -> u32 {
    x + y
}

// subtraction logic
pub fn sub_num(x: u32, y: u32) -> u32 {
    assert(x >= y, 'Result cannot be negative');
    x - y
}

// multiplication logic
pub fn mul_num(x: u32, y: u32) -> u32 {
    let result = x.checked_mul(y);
    assert(result.is_some(), 'Multiplication overflow');
    match result {
        Option::Some(val) => val,
        Option::None => panic!("Multiplication overflow"),
    }
}

// division logic
pub fn div_num(x: u32, y: u32) -> u32 {
    assert(y != 0, 'Division by zero');
    x / y
}

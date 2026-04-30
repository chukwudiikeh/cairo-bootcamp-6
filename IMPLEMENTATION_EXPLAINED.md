# Cairo Bootcamp 6 - Implementation Explained

---

## File 1: `cairo_program/src/integer.cairo`

This file contains basic arithmetic operations with safety checks.

---

### Main Function

```cairo
#[executable]
fn main() {
    let x: u32 = 10;
    let y: u32 = 5;
    
    println!("Addition: {} + {} = {}", x, y, add_num(x, y));
    println!("Subtraction: {} - {} = {}", x, y, sub_num(x, y));
    println!("Multiplication: {} * {} = {}", x, y, mul_num(x, y));
    println!("Division: {} / {} = {}", x, y, div_num(x, y));
}
```

**What it does:** Demonstrates all four arithmetic functions with sample values (10 and 5).

---

### Addition Function

```cairo
fn add_num(x: u32, y: u32) -> u32 {
    x + y
}
```

**What it does:** Takes two unsigned 32-bit integers and returns their sum.

---

### Subtraction Function

```cairo
fn sub_num(x: u32, y: u32) -> u32 {
    if x < y {
        panic!("Result cannot be negative");
    }
    x - y
}
```

**What it does:** Subtracts y from x, but panics if the result would be negative (since u32 can't represent negative numbers).

---

### Multiplication Function

```cairo
fn mul_num(x: u32, y: u32) -> u32 {
    match x.checked_mul(y) {
        Option::Some(val) => val,
        Option::None => panic!("Multiplication overflow"),
    }
}

7% > fn mul_num(x: u32, y: u32) -> u32 {
    match x.checked_mul(y) {
        Option::Some(val) => val,
        Option::None => panic!("Multiplication overflow"),
    }

> # Explaining mul_num Line by Line (ELI5 Style)

Line 1: fn mul_num(x: u32, y: u32) -> u32 {
This says: "I'm creating a function called mul_num. It takes two numbers (x and y), both are u32 (unsigned 32-bit integers, meaning whole numbers from 0 to 4,294,967,295). The function will give back one number (-> u32)."

Line 2: match x.checked_mul(y) {
This is the important part. checked_mul tries to multiply x and y. But here's the trick: instead of just doing the math, it checks if the answer is too big to fit in a u32. If it fits, great! If it doesn't fit (overflow), it returns a special "nothing" value. The match
keyword says: "Let me look at what happened and decide what to do next."

Line 3: Option::Some(val) => val,
This says: "If the multiplication worked and gave us a real answer, that answer is wrapped in Some(val). Just unwrap it and give back val." Think of it like opening a present — the answer is inside the box.

Line 4: Option::None => panic!("Multiplication overflow"),
This says: "If the multiplication was too big and failed, we get None (nothing). When that happens, crash the program and show the error message 'Multiplication overflow'." panic! is like hitting the emergency stop button.

Line 5: }
End of the match statement.

In simple terms: This function multiplies two numbers safely. If the answer is too big, it stops and tells you instead of giving you a wrong answer.
```

**What it does:** Multiplies two numbers safely. Uses `checked_mul` to detect overflow and panics if the result is too large for u32.

---

### Division Function

```cairo
fn div_num(x: u32, y: u32) -> u32 {
    if y == 0 {
        panic!("Division by zero");
    }
    x / y
}
```

**What it does:** Divides x by y, but panics if y is zero (division by zero is undefined).

---

## File 2: `cairo_program/src/lib.cairo`

```cairo
pub mod integer;
mod bytearray;
```

**What it does:** Exposes the `integer` module publicly so other crates can use it. The `bytearray` module is private.

---

## File 3: `starknet_contracts/src/lib.cairo`

This file contains a smart contract that uses the arithmetic functions from `cairo_program`.

---

### Interface Definition

```cairo
/// Interface representing `HelloContract`.
/// This interface allows modification and retrieval of the contract's storage count.
#[starknet::interface]
pub trait ICounter<T> {
    /// Increase count.
    fn increase_count(ref self: T, amount: u32);
    /// Decrease count.
    fn reduce_count(ref self: T, amount: u32);
    /// Multiply count.
    fn multiply_count(ref self: T, amount: u32);
    /// Divide count.
    fn divide_count(ref self: T, amount: u32);
    /// Retrieve count.
    fn get_count(self: @T) -> u32;
}
```

**What it does:** Defines the public interface for the Counter contract with five operations (increase, decrease, multiply, divide, and retrieve).

---

### Contract Definition

```cairo
/// Simple contract for managing count.
#[starknet::contract]
mod Counter {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_caller_address};
    use cairo_program::integer::{add_num, sub_num, mul_num, div_num};

    #[storage]
    struct Storage {
        count: u32,
        owner: ContractAddress,
    }
```

**What it does:**
- Imports storage access tools and caller identification
- Imports the four arithmetic functions from `cairo_program`
- Defines storage with a `count` (the current value) and `owner` (who can modify it)

---

### Constructor

```cairo
    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
    }
```

**What it does:** Runs once when the contract is deployed. Sets the owner address.

---

### Security Helper

```cairo
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn only_owner(self: @ContractState) {
            assert(get_caller_address() == self.owner.read(), 'Caller is not the owner');
        }
    }
```

**What it does:** Provides a reusable security check that ensures only the owner can call certain functions.

---

### Public Functions

```cairo
    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {
        fn increase_count(ref self: ContractState, amount: u32) {
            self.only_owner();
            assert(amount != 0, 'Amount cannot be 0');
            let current = self.count.read();
            let new_count = add_num(current, amount);
            self.count.write(new_count);
        }

        fn reduce_count(ref self: ContractState, amount: u32) {
            self.only_owner();
            let current = self.count.read();
            let new_count = sub_num(current, amount);
            self.count.write(new_count);
        }

        fn multiply_count(ref self: ContractState, amount: u32) {
            self.only_owner();
            assert(amount != 0, 'Amount cannot be 0');
            let current = self.count.read();
            let new_count = mul_num(current, amount);
            self.count.write(new_count);
        }

        fn divide_count(ref self: ContractState, amount: u32) {
            self.only_owner();
            assert(amount != 0, 'Amount cannot be 0');
            let current = self.count.read();
            let new_count = div_num(current, amount);
            self.count.write(new_count);
        }

        fn get_count(self: @ContractState) -> u32 {
            self.count.read()
        }
    }
}
```

**What it does:**
- `increase_count`: Adds amount to count (owner only, amount must be non-zero)
- `reduce_count`: Subtracts amount from count (owner only)
- `multiply_count`: Multiplies count by amount (owner only, amount must be non-zero)
- `divide_count`: Divides count by amount (owner only, amount must be non-zero)
- `get_count`: Returns current count (anyone can call)

Each state-changing function:
1. Checks that the caller is the owner
2. Validates input (amount != 0 where applicable)
3. Reads the current count
4. Calls the appropriate arithmetic function
5. Writes the new count to storage

---

## How It All Works Together

1. **cairo_program** provides safe arithmetic functions with overflow/underflow checks
2. **starknet_contracts** uses these functions in a smart contract
3. The contract stores a count value on the blockchain
4. Only the owner can modify the count
5. Anyone can read the current count
6. All operations use the safe arithmetic functions to prevent errors

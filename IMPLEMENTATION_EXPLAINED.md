# Cairo Counter Contract - Line by Line (Explain Like I'm 5)

---

## File 1: `cairo_program/src/integer.cairo`

This file is like a toolbox with 4 basic math tools.

---

### Addition Function

```cairo
pub fn add_num(x: u32, y: u32) -> u32 {
```
**Line 1:** "Hey everyone, I'm making a tool called add_num!"
- `pub` = everyone can use this tool (not private)
- `fn` = I'm making a tool (function)
- `add_num` = the tool's name
- `x: u32, y: u32` = give me two whole numbers (like 5 and 3)
- `-> u32` = I'll give you back one whole number

```cairo
    x + y
```
**Line 2:** Add the two numbers like 5 + 3 = 8, and give back the answer

```cairo
}
```
**Line 3:** "I'm done making this tool!"

---

### Subtraction Function

```cairo
pub fn sub_num(x: u32, y: u32) -> u32 {
```
**Line 1:** "Hey everyone, I'm making a tool called sub_num!"
- Give me two numbers, I'll give you back one number

```cairo
    assert(x >= y, 'Result cannot be negative');
```
**Line 2:** "Wait! Let me check something first!"
- `assert()` = like a safety guard that says "STOP!" if something is wrong
- `x >= y` = is the first number bigger than or equal to the second? (like: is 10 ≥ 3?)
- If not (like 3 - 10), yell: 'Result cannot be negative'
- Why? You can't have -7 apples! Our numbers don't do negatives.

```cairo
    x - y
```
**Line 3:** Okay, safe to subtract! Do 10 - 3 = 7 and give back the answer

```cairo
}
```
**Line 4:** "I'm done making this tool!"

---

### Multiplication Function

```cairo
pub fn mul_num(x: u32, y: u32) -> u32 {
```
**Line 1:** "Hey everyone, I'm making a tool called mul_num!"

```cairo
    let result = x.checked_mul(y);
```
**Line 2:** "Let me try to multiply these numbers carefully..."
- `let result =` = make a box to hold the answer
- `x.checked_mul(y)` = multiply like 5 × 3, but check if the answer is TOO BIG
- If it works: put the answer in a gift box labeled "Some(15)"
- If too big: put nothing in the box, label it "None"
- Example: trying to count 4 billion × 2 = way too many to count!

```cairo
    assert(result.is_some(), 'Multiplication overflow');
```
**Line 3:** "Did I get an answer, or was it too big?"
- `result.is_some()` = is there a number in the box?
- If the box is empty (None), yell: 'Multiplication overflow' (too big!)

```cairo
    result.unwrap()
```
**Line 4:** "Open the gift box and take out the number!"
- `unwrap()` = open the box and grab the number inside
- Safe because we already checked the box isn't empty

```cairo
}
```
**Line 5:** "I'm done making this tool!"

---

### Division Function

```cairo
pub fn div_num(x: u32, y: u32) -> u32 {
```
**Line 1:** "Hey everyone, I'm making a tool called div_num!"

```cairo
    assert(y != 0, 'Division by zero');
```
**Line 2:** "Wait! You can't divide by zero!"
- `y != 0` = is the second number NOT zero?
- If it IS zero, yell: 'Division by zero'
- Why? If you have 10 cookies and try to share them among 0 friends... that makes no sense!

```cairo
    x / y
```
**Line 3:** Okay, safe to divide! Do 10 ÷ 2 = 5 and give back the answer

```cairo
}
```
**Line 4:** "I'm done making this tool!"

---

## File 2: `cairo_program/src/lib.cairo`

```cairo
pub mod integer;
```
**This line:** "Hey, I have a toolbox called 'integer' and everyone can use it!"
- `pub` = everyone can borrow my tools
- `mod integer` = the toolbox is in the file called `integer.cairo`
- This lets the smart contract use our math tools

---

## File 3: `starknet_contracts/src/lib.cairo`

This is like building a special calculator that lives on the blockchain!

---

### Interface Definition (The Menu)

```cairo
#[starknet::interface]
```
**Line 1:** "I'm making a menu that shows what buttons my calculator has!"

```cairo
pub trait ICounter<T> {
```
**Line 2:** "The menu is called ICounter"
- `pub` = everyone can see this menu
- `trait` = this is a list of buttons (not the actual buttons yet)

```cairo
    fn increase_count(ref self: T, amount: u32);
```
**Line 3:** "Button 1: Make the number bigger"
- `ref self: T` = this button can change what's on the screen
- `amount: u32` = you tell me how much to add

```cairo
    fn reduce_count(ref self: T, amount: u32);
```
**Line 4:** "Button 2: Make the number smaller"

```cairo
    fn multiply_count(ref self: T, amount: u32);
```
**Line 5:** "Button 3: Multiply the number"

```cairo
    fn divide_count(ref self: T, amount: u32);
```
**Line 6:** "Button 4: Divide the number"

```cairo
    fn get_count(self: @T) -> u32;
```
**Line 7:** "Button 5: Just look at the number (don't change it)"
- `self: @T` = this button only LOOKS, can't change anything
- `-> u32` = tells you what number is on the screen

```cairo
}
```
**Line 8:** "That's all the buttons on my menu!"

---

### Contract Definition

```cairo
#[starknet::contract]
```
**Line 1:** "Now I'm building the ACTUAL calculator (not just the menu)!"

```cairo
mod Counter {
```
**Line 2:** "My calculator is called Counter"

---

### Imports (Getting Tools)

```cairo
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
```
**Line 3:** "I need tools to save and read numbers from the blockchain!"
- `StoragePointerReadAccess` = tool to READ saved numbers
- `StoragePointerWriteAccess` = tool to WRITE/SAVE numbers

```cairo
    use starknet::{ContractAddress, get_caller_address};
```
**Line 4:** "I need tools to know WHO is using my calculator!"
- `ContractAddress` = like a home address, but for blockchain accounts
- `get_caller_address` = tells me who just pressed a button

```cairo
    use cairo_program::integer::{add_num, sub_num, mul_num, div_num};
```
**Line 5:** "I'm borrowing the 4 math tools we made earlier!"
- Brings in add, subtract, multiply, and divide from our toolbox

---

### Storage (The Calculator's Memory)

```cairo
    #[storage]
```
**Line 6:** "Here's what my calculator remembers forever:"

```cairo
    struct Storage {
```
**Line 7:** "I have a memory box with 2 things in it:"

```cairo
        count: u32,
```
**Line 8:** "Thing 1: The number on the screen (called 'count')"

```cairo
        owner: ContractAddress,
```
**Line 9:** "Thing 2: The address of who owns this calculator"
- Like writing your name on your calculator so others can't use it

```cairo
    }
```
**Line 10:** "That's everything I remember!"

---

### Constructor (First Time Setup)

```cairo
    #[constructor]
```
**Line 11:** "This runs ONE TIME when someone first creates the calculator!"

```cairo
    fn constructor(ref self: ContractState, owner: ContractAddress) {
```
**Line 12:** "Setup function - tell me who the owner is!"
- `ref self: ContractState` = I can write to memory
- `owner: ContractAddress` = give me the owner's address

```cairo
        self.owner.write(owner);
```
**Line 13:** "Write the owner's name in permanent marker!"
- `self.owner` = the owner spot in memory
- `.write(owner)` = save the owner's address to the blockchain forever

```cairo
    }
```
**Line 14:** "Setup complete!"

---

### Internal Helper (Security Guard)

```cairo
    #[generate_trait]
```
**Line 15:** "Make a special helper tool automatically"

```cairo
    impl InternalImpl of InternalTrait {
```
**Line 16:** "Here are my private helper tools:"

```cairo
        fn only_owner(self: @ContractState) {
```
**Line 17:** "Security guard tool - checks if you're the owner!"
- `self: @ContractState` = I only need to LOOK at memory, not change it

```cairo
            assert(get_caller_address() == self.owner.read(), 'Caller is not the owner');
```
**Line 18:** "Are you the owner? Let me check your ID!"
- `get_caller_address()` = who are you?
- `self.owner.read()` = who is the owner?
- `==` = are these the same person?
- If NO, yell: 'Caller is not the owner' and kick them out!

```cairo
        }
```
**Line 19:** "Security check done!"

```cairo
    }
```
**Line 20:** "All helper tools defined!"

---

### Public Functions (The Actual Buttons!)

```cairo
    #[abi(embed_v0)]
```
**Line 21:** "These buttons can be pressed from outside the calculator!"

```cairo
    impl CounterImpl of super::ICounter<ContractState> {
```
**Line 22:** "Now I'm building the REAL buttons from the menu we made earlier!"

---

### Increase Count Button

```cairo
        fn increase_count(ref self: ContractState, amount: u32) {
```
**Line 23:** "The '+' button - makes the number bigger!"

```cairo
            self.only_owner();
```
**Line 24:** "STOP! Security guard, check their ID!"
- Calls the security guard we made earlier
- If not the owner, they get kicked out here

```cairo
            assert(amount != 0, 'Amount cannot be 0');
```
**Line 25:** "You can't add zero! That's silly!"
- `amount != 0` = is the amount NOT zero?
- If it IS zero, yell: 'Amount cannot be 0'

```cairo
            let current = self.count.read();
```
**Line 26:** "Let me check what number is on the screen right now..."
- `let current =` = make a box called 'current'
- `self.count.read()` = read the number from the calculator's memory

```cairo
            let new_count = add_num(current, amount);
```
**Line 27:** "Use my add tool to calculate: current + amount"
- Calls our `add_num` function from the toolbox
- Example: if screen shows 10 and you add 5, new_count = 15

```cairo
            self.count.write(new_count);
```
**Line 28:** "Write the new number on the screen and save it forever!"
- `self.count.write()` = save the new number to blockchain memory

```cairo
        }
```
**Line 29:** "'+' button is done!"

---

### Reduce Count Button

```cairo
        fn reduce_count(ref self: ContractState, amount: u32) {
```
**Line 30:** "The '-' button - makes the number smaller!"

```cairo
            self.only_owner();
```
**Line 31:** "Security guard, check their ID!"

```cairo
            let current = self.count.read();
```
**Line 32:** "What number is on the screen?"

```cairo
            let new_count = sub_num(current, amount);
```
**Line 33:** "Use my subtract tool: current - amount"
- Calls our safe `sub_num` function
- If the answer would be negative (like 3 - 10), it will yell an error!

```cairo
            self.count.write(new_count);
```
**Line 34:** "Write the new number on the screen!"

```cairo
        }
```
**Line 35:** "'-' button is done!"

---

### Multiply Count Button

```cairo
        fn multiply_count(ref self: ContractState, amount: u32) {
```
**Line 36:** "The '×' button - makes the number bigger by multiplying!"

```cairo
            self.only_owner();
```
**Line 37:** "Security guard, check their ID!"

```cairo
            let current = self.count.read();
```
**Line 38:** "What number is on the screen?"

```cairo
            let new_count = mul_num(current, amount);
```
**Line 39:** "Use my multiply tool: current × amount"
- Calls our safe `mul_num` function
- If the answer is too big (overflow), it will yell an error!

```cairo
            self.count.write(new_count);
```
**Line 40:** "Write the new number on the screen!"

```cairo
        }
```
**Line 41:** "'×' button is done!"

---

### Divide Count Button

```cairo
        fn divide_count(ref self: ContractState, amount: u32) {
```
**Line 42:** "The '÷' button - makes the number smaller by dividing!"

```cairo
            self.only_owner();
```
**Line 43:** "Security guard, check their ID!"

```cairo
            let current = self.count.read();
```
**Line 44:** "What number is on the screen?"

```cairo
            let new_count = div_num(current, amount);
```
**Line 45:** "Use my divide tool: current ÷ amount"
- Calls our safe `div_num` function
- If you try to divide by zero, it will yell an error!

```cairo
            self.count.write(new_count);
```
**Line 46:** "Write the new number on the screen!"

```cairo
        }
```
**Line 47:** "'÷' button is done!"

---

### Get Count Button (Just Look!)

```cairo
        fn get_count(self: @ContractState) -> u32 {
```
**Line 48:** "The 'look' button - just shows you the number!"
- `self: @ContractState` = I only LOOK, I don't change anything (notice the `@`)
- `-> u32` = I'll tell you what number is on the screen
- NO security guard! Anyone can look!

```cairo
            self.count.read()
```
**Line 49:** "Here's the number on the screen!"
- Just read and tell you the number, that's it!

```cairo
        }
```
**Line 50:** "'Look' button is done!"

```cairo
    }
```
**Line 51:** "All buttons are built!"

```cairo
}
```
**Line 52:** "Calculator is complete!"

---

## Configuration Files (Setup Instructions)

### `cairo_program/Scarb.toml`

```toml
name = "cairo_program"
```
**What we did:** Changed the name to `cairo_program`
- Like naming your toolbox so others can find it
- The smart contract needs to know what to call it when borrowing tools

### `starknet_contracts/Scarb.toml`

```toml
cairo_program = { path = "../cairo_program" }
```
**What we did:** Told the calculator where to find the toolbox
- `cairo_program` = the toolbox name
- `path = "../cairo_program"` = go up one folder, then into cairo_program folder
- Like giving directions: "The tools are in the garage!"

### `cairo_program/src/lib.cairo`

```cairo
pub mod integer;
```
**What we did:** Opened the toolbox door
- `pub` = everyone can borrow these tools
- Without this, the tools would be locked inside and nobody could use them!

---

## How Everything Works Together (Story Time!)

1. **You create the calculator** → You become the owner, screen shows 0
2. **You press the '+10' button** → Screen now shows 10
3. **You press the '×3' button** → Screen now shows 30
4. **You press the '÷5' button** → Screen now shows 6
5. **Your friend presses 'look'** → They see 6 (anyone can look!)
6. **Your friend tries to press '+5'** → ❌ Security guard says "You're not the owner!" and kicks them out
7. **You press '-10'** → Screen now shows -4... WAIT! ❌ The subtract tool yells "Result cannot be negative!" and stops you

The calculator is safe because:
- Only YOU can change the numbers (owner protection)
- It won't let you make mistakes (error checking)
- Everyone can see the number, but only you can change it
- All the numbers are saved on the blockchain forever!

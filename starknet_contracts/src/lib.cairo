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
    fn divide_count(ref self: T, amount: u32);`
    /// Retrieve count.
    fn get_count(self: @T) -> u32;
}

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

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn only_owner(self: @ContractState) {
            assert(get_caller_address() == self.owner.read(), 'Caller is not the owner');
        }
    }

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

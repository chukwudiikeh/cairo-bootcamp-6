use starknet::ContractAddress;

#[starknet::interface]
pub trait IERC20<TContractState> {
    fn get_name(self: @TContractState) -> felt252;
    fn get_symbol(self: @TContractState) -> felt252;
    fn get_decimals(self: @TContractState) -> u8;
    fn get_total_supply(self: @TContractState) -> felt252;
    fn balance_of(self: @TContractState, account: ContractAddress) -> felt252;
    fn allowance(
        self: @TContractState, owner: ContractAddress, spender: ContractAddress,
    ) -> felt252;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: felt252);
    fn transfer_from(
        ref self: TContractState,
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: felt252,
    );
    fn approve(ref self: TContractState, spender: ContractAddress, amount: felt252);
    fn increase_allowance(ref self: TContractState, spender: ContractAddress, added_value: felt252);
    fn decrease_allowance(
        ref self: TContractState, spender: ContractAddress, subtracted_value: felt252,
    );
    fn burn(ref self: TContractState, amount: felt252);
    fn revoke(ref self: TContractState, account: ContractAddress);
    fn update_transfer_limit(ref self: TContractState, new_limit: u256);
    fn get_transfer_limit(self: @TContractState) -> u256;
}
#[starknet::contract]
pub mod erc20 {

    use core::num::traits::Zero;
    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use starknet::storage::{ Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,StoragePointerWriteAccess,};

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        decimals: u8,
        total_supply: felt252,
        balances: Map::<ContractAddress, felt252>,
        allowances: Map::<(ContractAddress, ContractAddress), felt252>,
        admin: ContractAddress,
        transfer_limit: u256,
        revoked: Map::<ContractAddress, bool>,
    }

    #[event]
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub enum Event {
        Transfer: Transfer,
        Approval: Approval,
        Burn: Burn,
        Revoke: Revoke,
        LimitUpdated: LimitUpdated,
    }
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub struct Transfer {
        pub from: ContractAddress,
        pub to: ContractAddress,
        pub value: felt252,
    }
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub struct Approval {
        pub owner: ContractAddress,
        pub spender: ContractAddress,
        pub value: felt252,
    }
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub struct Burn {
        pub from: ContractAddress,
        pub value: felt252,
    }
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub struct Revoke {
        pub account: ContractAddress,
    }
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub struct LimitUpdated {
        pub new_limit: felt252,
    }

    mod Errors {
        pub const APPROVE_FROM_ZERO: felt252 = 'ERC20: approve from 0';
        pub const APPROVE_TO_ZERO: felt252 = 'ERC20: approve to 0';
        pub const TRANSFER_FROM_ZERO: felt252 = 'ERC20: transfer from 0';
        pub const TRANSFER_TO_ZERO: felt252 = 'ERC20: transfer to 0';
        pub const BURN_FROM_ZERO: felt252 = 'ERC20: burn from 0';
        pub const MINT_TO_ZERO: felt252 = 'ERC20: mint to 0';
        pub const TRANSFER_LIMIT_EXCEEDED: felt252 = 'ERC20: transfer limit exceeded';
        pub const ACCOUNT_REVOKED: felt252 = 'ERC20: account revoked';
        pub const UNAUTHORIZED: felt252 = 'ERC20: unauthorized';
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        recipient: ContractAddress,
        name: felt252,
        decimals: u8,
        initial_supply: felt252,
        symbol: felt252,
    ) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.decimals.write(decimals);
        self.admin.write(get_caller_address());
        self.transfer_limit.write(10000_u256);
        self.mint(recipient, initial_supply);
    }

    #[abi(embed_v0)]
    impl IERC20Impl of super::IERC20<ContractState> {
        fn get_name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn get_symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn get_decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }

        fn get_total_supply(self: @ContractState) -> felt252 {
            self.total_supply.read()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> felt252 {
            self.balances.read(account)
        }

        fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress,) -> felt252 {
            self.allowances.read((owner, spender))
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: felt252) {
            let sender = get_caller_address();
            self._transfer(sender, recipient, amount);
        }

        fn transfer_from(ref self: ContractState,sender: ContractAddress,recipient: ContractAddress,amount: felt252,) {
            let caller = get_caller_address();
            self.spend_allowance(sender, caller, amount);
            self._transfer(sender, recipient, amount);
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: felt252) {
            let caller = get_caller_address();
            self.approve_helper(caller, spender, amount);
        }

        fn increase_allowance(ref self: ContractState, spender: ContractAddress, added_value: felt252) {
            let caller = get_caller_address();
            self.approve_helper(caller, spender, self.allowances.read((caller, spender)) + added_value,);
        }

        fn decrease_allowance(ref self: ContractState, spender: ContractAddress, subtracted_value: felt252,) {
            let caller = get_caller_address();
            self.approve_helper(caller, spender, self.allowances.read((caller, spender)) - subtracted_value);
        }

        fn burn(ref self: ContractState, amount: felt252) {
            let caller = get_caller_address();
            assert(caller == self.admin.read(), Errors::UNAUTHORIZED);
            assert(caller.is_non_zero(), Errors::BURN_FROM_ZERO);
            self.balances.write(caller, self.balances.read(caller) - amount);
            self.total_supply.write(self.total_supply.read() - amount);
            self.emit(Event::Burn(Burn { from: caller, value: amount }));
        }

        fn revoke(ref self: ContractState, account: ContractAddress) {
            assert(get_caller_address() == self.admin.read(), Errors::UNAUTHORIZED);
            self.revoked.write(account, true);
            self.emit(Event::Revoke(Revoke { account }));
        }

        fn update_transfer_limit(ref self: ContractState, new_limit: u256) {
            assert(get_caller_address() == self.admin.read(), Errors::UNAUTHORIZED);
            self.transfer_limit.write(new_limit);
            self.emit(Event::LimitUpdated(LimitUpdated { new_limit: new_limit.try_into().unwrap() }));
        }

        fn get_transfer_limit(self: @ContractState) -> u256 {
            self.transfer_limit.read()
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _transfer(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: felt252,
        ) {
            assert(sender.is_non_zero(), Errors::TRANSFER_FROM_ZERO);
            assert(recipient.is_non_zero(), Errors::TRANSFER_TO_ZERO);
            assert(!self.revoked.read(sender), Errors::ACCOUNT_REVOKED);
            let limit = self.transfer_limit.read();
            let amount_u256: u256 = amount.into();
            assert(amount_u256 <= limit, Errors::TRANSFER_LIMIT_EXCEEDED);
            self.balances.write(sender, self.balances.read(sender) - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.emit(Transfer { from: sender, to: recipient, value: amount });
        }

        fn spend_allowance(
            ref self: ContractState,
            owner: ContractAddress,
            spender: ContractAddress,
            amount: felt252,
        ) {
            let allowance = self.allowances.read((owner, spender));
            self.allowances.write((owner, spender), allowance - amount);
        }

        fn approve_helper(
            ref self: ContractState,
            owner: ContractAddress,
            spender: ContractAddress,
            amount: felt252,
        ) {
            assert(spender.is_non_zero(), Errors::APPROVE_TO_ZERO);
            self.allowances.write((owner, spender), amount);
            self.emit(Approval { owner, spender, value: amount });
        }

        fn mint(ref self: ContractState, recipient: ContractAddress, amount: felt252) {
            assert(recipient.is_non_zero(), Errors::MINT_TO_ZERO);
            let supply = self.total_supply.read() + amount;
            self.total_supply.write(supply);
            let balance = self.balances.read(recipient) + amount;
            self.balances.write(recipient, balance);
            self.emit(Event::Transfer(Transfer {from: Zero::zero(), to: recipient, value: amount},),);
        }
    }
}
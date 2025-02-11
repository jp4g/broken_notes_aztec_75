use crate::BrokenNoteDemo;
use aztec::{prelude::AztecAddress, test::helpers::{cheatcodes, test_environment::TestEnvironment}};
use aztec::oracle::random::random;

pub struct TestAccounts {
    deployer: AztecAddress,
    alice: AztecAddress,
    bob: AztecAddress,
}

pub struct TestContracts {
    broken_note: AztecAddress,
}

pub unconstrained fn setup() -> (&mut TestEnvironment, TestAccounts, TestContracts) {
    let mut env = TestEnvironment::new();

    // create accounts
    let accounts = TestAccounts {
        deployer: env.create_account_contract(1),
        alice: env.create_account_contract(2),
        bob: env.create_account_contract(3),
    };


    let contracts = TestContracts {
        broken_note: deploy_broken_note_contract(&mut env, accounts.deployer)
    };

    // return setup params
    (&mut env, accounts, contracts)
}


pub unconstrained fn deploy_broken_note_contract(
    env: &mut TestEnvironment,
    deployer: AztecAddress,
) -> AztecAddress {
    env.impersonate(deployer);
    let escrow_init_call_iface = BrokenNoteDemo::interface().constructor();
    let broken_note_contract = env
        .deploy("./@broken_notes", "BrokenNoteDemo")
        .with_public_void_initializer(escrow_init_call_iface);
    cheatcodes::advance_blocks_by(1);
    broken_note_contract.to_address()
}

pub unconstrained fn call_make_note(
    env: &mut TestEnvironment,
    broken_note_contract: AztecAddress,
    account: AztecAddress,
    data: Field,
) {
    env.impersonate(account);
    BrokenNoteDemo::at(broken_note_contract).make_note(data).call(&mut env.private());
    cheatcodes::advance_blocks_by(1);
}

pub unconstrained fn call_function(
    env: &mut TestEnvironment,
    broken_note_contract: AztecAddress,
    account: AztecAddress,
) {
    env.impersonate(account);
    BrokenNoteDemo::at(broken_note_contract).function().call(&mut env.private());
    cheatcodes::advance_blocks_by(1);
}


#[test]
unconstrained fn test_working_note() {
    let (env, accounts, contracts) = setup();
    let data = unsafe { random() };
    // create note
    call_make_note(env, contracts.broken_note, accounts.alice, data);
}

#[test]
unconstrained fn test_broken_note() {
    let (env, accounts, contracts) = setup();
    let data = unsafe { random() };
    // create note
    call_make_note(env, contracts.broken_note, accounts.alice, data);

    // works fine
    call_function(env, contracts.broken_note, accounts.alice);
}

#[test_only]
module owner::counter_tests {
    use std::signer;
    use std::vector;
    use std::unit_test;
    use std::debug;
    use owner::counter;

    fun get_account(): signer {
        vector::pop_back(&mut unit_test::create_signers_for_testing(1))
    }

    #[test]
    public entry fun count_test() {
        let account = get_account();
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);

        counter::set_count(account);
        let count = counter::get_count(addr);
        debug::print(&count);
        assert!(counter::get_count(addr) == 0, 0);

        let account = get_account();
        counter::set_count(account);
        assert!(counter::get_count(addr) == 1, 0);

    }
}

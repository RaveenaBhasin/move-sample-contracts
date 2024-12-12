module hello_blockchain::counter {
    use std::signer;
    struct Counter has key, store {
        number: u64
    }

    #[view]
    public fun get_count(addr: address): u64 acquires Counter {
        assert!(exists<Counter>(addr), 0);
        borrow_global<Counter>(addr).number
    }

    public entry fun set_count(account: signer) acquires Counter {
        let addr = signer::address_of(&account);
        if (!exists<Counter>(addr)) {
            move_to(&account, Counter { number: 0 })
        } else {
            let old_number = borrow_global_mut<Counter>(addr);
            old_number.number = old_number.number + 1;
        }
    }
}

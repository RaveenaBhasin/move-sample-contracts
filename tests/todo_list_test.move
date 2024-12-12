#[test_only]
module owner::todo_list_tests {
    use std::unit_test;
    use std::signer;
    use std::debug;
    use std::string;
    use std::vector;
    use owner::todo_list;

    fun get_account(): signer {
        vector::pop_back(&mut unit_test::create_signers_for_testing(1))
    }

    #[test]
    public entry fun test_e2e() {
        let account = get_account();
        let addr = signer::address_of(&account);
        aptos_framework::account::create_account_for_test(addr);
        todo_list::create_list(&account);
        let description = string::utf8(b"Read vitalik blogs");
        todo_list::add_task(&account, description);
        let description = string::utf8(b"Write Tests for TodoList Contract");
        todo_list::add_task(&account, description);
        let tasks = todo_list::get_tasks(addr);
        debug::print(&string::utf8(b"Tasks"));
        debug::print(&tasks);
        debug::print(&string::utf8(b"Mark Task 1 as finished"));
        todo_list::complete_task(&account, 1);
        debug::print(&string::utf8(b"Updated Task List"));
        let tasks = todo_list::get_tasks(addr);
        debug::print(&tasks);
        debug::print(&string::utf8(b"Remove task 1"));
        todo_list::remove_task(&account, 1);
        debug::print(&string::utf8(b"Updated Task List"));
        let tasks = todo_list::get_tasks(addr);
        debug::print(&tasks);
    }
}


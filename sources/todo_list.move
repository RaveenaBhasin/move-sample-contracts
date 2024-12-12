module owner::todo_list {
    use std::signer;
    use std::vector;
    use std::string::String;
    use aptos_framework::event;

    struct Task has store, copy, drop {
        id: u64,
        description: String,
        completed: bool,
    }

    struct TodoList has key {
        todo_list: vector<Task>,
        next_task_id: u64
    }

    #[event]
    struct AddTaskEvent has drop, store {
        account: address,
        task_id: u64,
        description: String
    }

    const E_TODO_LIST_DONOT_EXIST: u64 = 1;
    const E_TASK_ALREADY_COMPLETED: u64 = 2;
    const E_TASK_NOT_FOUND: u64 = 3;

    #[view]
    public fun get_tasks(addr: address): vector<Task> acquires TodoList {
        assert!(exists<TodoList>(addr), E_TODO_LIST_DONOT_EXIST);
        borrow_global<TodoList>(addr).todo_list
    }

    #[view]
    public fun get_task_count(addr: address): u64 acquires TodoList {
        assert!(exists<TodoList>(addr), E_TODO_LIST_DONOT_EXIST);
        let todo_list = borrow_global<TodoList>(addr).todo_list;
        vector::length(&todo_list)
    }

    #[view]
    public fun get_incomplete_task(addr: address): vector<Task> acquires TodoList {
        assert!(exists<TodoList>(addr), E_TODO_LIST_DONOT_EXIST);

        let todo_list: &TodoList = borrow_global<TodoList>(addr);
        let todo_items = &todo_list.todo_list;

        let incomplete_tasks = vector::empty<Task>();
        let length = vector::length(todo_items);
        let i = 0;
        while (i < length) {
            let task = vector::borrow(todo_items, i);
            if (!task.completed) {
                vector::push_back(&mut incomplete_tasks, *task);
            };
            i = i + 1;
        };
        incomplete_tasks
    }

    public entry fun create_list(account: &signer) {
        let addr = signer::address_of(account);
        if (!exists<TodoList>(addr)) {
            move_to(
                account,
                TodoList { todo_list: vector::empty(), next_task_id: 0 }
            )
        }
    }

    public entry fun add_task(account: &signer, description: String) acquires TodoList {
        let addr = signer::address_of(account);
        assert!(exists<TodoList>(addr), E_TODO_LIST_DONOT_EXIST);
        let todo_list: &mut TodoList = borrow_global_mut<TodoList>(addr);
        let new_task = Task {
            id: todo_list.next_task_id,
            description,
            completed: false,
        };
        let task_id = new_task.id;
        vector::push_back(&mut todo_list.todo_list, new_task);
        todo_list.next_task_id = todo_list.next_task_id + 1;
        event::emit(
                AddTaskEvent {
                    account: addr,
                    task_id,
                    description 
                }
            );

    }

    public entry fun complete_task(account: &signer, task_id: u64) acquires TodoList {
        let addr = signer::address_of(account);
        assert!(exists<TodoList>(addr), E_TODO_LIST_DONOT_EXIST);
        let todo_list: &mut TodoList = borrow_global_mut<TodoList>(addr);
        let todo_items = &todo_list.todo_list;
        let length = vector::length(todo_items);
        let i = 0;
        let found = false;
        while (i < length) {
            let task = vector::borrow(todo_items, i);
            if (task.id == task_id) {
                found = true;
                break
            };
            i = i + 1;
        };
        assert!(found, E_TASK_NOT_FOUND);
        let task_ref = vector::borrow_mut(&mut todo_list.todo_list, i);
        assert!(!task_ref.completed, E_TASK_ALREADY_COMPLETED);
        task_ref.completed = true;
    }

    public entry fun remove_task(account: &signer, task_id: u64) acquires TodoList {
        let addr = signer::address_of(account);
        assert!(exists<TodoList>(addr), E_TODO_LIST_DONOT_EXIST);
        let todo_list: &mut TodoList = borrow_global_mut<TodoList>(addr);
        let todo_items = &todo_list.todo_list;
        let length = vector::length(todo_items);
        let i: u64 = 0;
        let found = false;
        while (i < length) {
            let task = vector::borrow(todo_items, i);
            if (task.id == task_id) {
                found = true;
                break
            };
            i = i + 1;
        };
        assert!(found, E_TASK_NOT_FOUND);
        vector::remove(&mut todo_list.todo_list, i);
    }
}

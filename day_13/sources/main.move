module challenge::day_13
{
    use std::string::String;

    public enum TaskStatus has copy, drop
    {
        Open        ,
        Completed   ,
    }

    public struct Task has copy, drop
    {
        title   : String    ,
        reward  : u64       ,
        status  : TaskStatus,
    }

    public fun new_task(title: String, reward: u64): Task
    {
        Task
        {
            title  : title              ,
            reward : reward             ,
            status : TaskStatus::Open   ,
        }
    }

    public struct TaskBoard has drop
    {
        owner: address      ,
        tasks: vector<Task> ,
    }

    public fun new_board(owner: address): TaskBoard
    {
        TaskBoard
        {
            owner: owner                ,
            tasks: vector::empty<Task>(),
        }
    }

    public fun add_task(board: &mut TaskBoard, task: Task)
    {
        vector::push_back(&mut board.tasks, task);
    }

    public fun is_open(task: &Task): bool
    {
        task.status == TaskStatus::Open
    }

    public fun complete_task(task: &mut Task)
    {
        task.status = TaskStatus::Completed;
    }

    public fun has_valid_reward(task: &Task): bool
    {
        internal_helper(task.reward)
    }

    fun internal_helper(reward: u64): bool
    {
        reward > 0
    }

    public fun find_task_by_title(board: &TaskBoard, title: &String): Option<u64>
    {
        let     len = vector::length(&board.tasks);

        let mut i   = 0;

        while  (i < len)
        {
            let task = vector::borrow(&board.tasks, i);

            if (&task.title == title)
            {
                return option::some(i)
            };

            i = i + 1;
        };

        option::none<u64>()
    }

    public fun total_reward(board: &TaskBoard): u64
    {
        let     len = vector::length(&board.tasks);

        let mut res = 0;
        let mut i   = 0;

        while (i < len)
        {
            let task = vector::borrow(&board.tasks, i);

            res = res + task.reward;

            i = i + 1;
        };
        res
    }

    public fun completed_count(board: &TaskBoard): u64
    {
        let     len = vector::length(&board.tasks);

        let mut res = 0;
        let mut i   = 0;

        while (i < len)
        {
            let task = vector::borrow(&board.tasks, i);

            if (task.status == TaskStatus::Completed)
            {
                res = res + 1;
            };

            i = i + 1;
        };
        res
    }
}

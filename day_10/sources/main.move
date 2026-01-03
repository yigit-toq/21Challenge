module challenge::day_10
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
}

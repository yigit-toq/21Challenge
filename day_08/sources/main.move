module challenge::day_08
{
    use std::string::String;

    public struct Task has copy, drop
    {
        title   : String,
        done    : bool  ,
        reward  : u64   ,
    }

    public fun new_task(title: String, reward: u64): Task
    {
        Task
        {
            title  : title  ,
            done   : false  ,
            reward : reward ,
        }
    }
}

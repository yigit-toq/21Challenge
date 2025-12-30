module challenge::day_07
{
    use std::string::{Self, String};

    public struct Habit has copy, drop
    {
        name        : String,
        completed   : bool  ,
    }

    public fun new_habit(name: String) : Habit
    {
        Habit
        {
            name,
            completed: false,
        }
    }

    public struct HabitList has drop
    {
        habits: vector<Habit>
    }

    public fun empty_list(): HabitList
    {
        HabitList
        {
            habits: vector::empty<Habit>()
        }
    }

    public fun add_habit(list: &mut HabitList, habit: Habit)
    {
        vector::push_back(&mut list.habits, habit);
    }

    public fun complete_habit(list: &mut HabitList, index: u64)
    {
        let length = vector::length(&list.habits);

        if (index < length)
        {
            let habit = vector::borrow_mut(&mut list.habits, index);

            habit.completed = true;
        }
    }

    public fun make_habit(name_bytes: vector<u8>) : Habit
    {
        new_habit(string::utf8(name_bytes))
    }

    #[test]
    fun test_empty_list()
    {
        let list = empty_list();

        assert!(vector::length(&list.habits) == 0, 0);
    }

    #[test]
    fun test_add_habits()
    {
        let mut list = empty_list();

        let habit1 = make_habit(b"habit1");
        let habit2 = make_habit(b"habit2");
        
        add_habit(&mut list, habit1);
        add_habit(&mut list, habit2);

        assert!(vector::length(&list.habits) == 2, 0);
    }

    #[test]
    fun test_complete_habit()
    {
        let mut list = empty_list();

        add_habit(&mut list, make_habit(b"habit1"));
        add_habit(&mut list, make_habit(b"habit2"));

        complete_habit(&mut list, 0);

        let f_habit = vector::borrow(&list.habits, 0);
        let s_habit = vector::borrow(&list.habits, 1);

        assert!(f_habit.completed == true , 0);
        assert!(s_habit.completed == false, 1);
    }
}

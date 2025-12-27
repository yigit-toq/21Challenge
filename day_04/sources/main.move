module challenge::day_04
{
    public struct Habit has copy, drop
    {
        name: vector<u8>,
        completed: bool ,
    }

    public fun new_habit(name: vector<u8>) : Habit
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

    #[test]
    fun test_empty_list()
    {
        let list = empty_list();
        assert!(vector::length(&list.habits) == 0, 0);
    }

    #[test]
    fun test_add_habit()
    {
        let mut list = empty_list();

        let habit1 = new_habit(b"habit1");
        let habit2 = new_habit(b"habit2");
        
        add_habit(&mut list, habit1);
        add_habit(&mut list, habit2);

        assert!(vector::length(&list.habits) == 2, 0);
    }
}

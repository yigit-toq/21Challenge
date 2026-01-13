module challenge::day_15
{
    const MAX_PLOTS             : u64 = 20;

    const E_PLOT_NOT_FOUND      : u64 = 1;
    const E_PLOT_EXC_LIMIT      : u64 = 2;
    const E_PLOT_INVALID_ID     : u64 = 3;
    const E_PLOT_ALREADY_EXISTS : u64 = 4;

    public struct FarmCounters has copy, drop, store
    {
        harvested   : u64,
        planted     : u64,
        plots       : vector<u8>,
    }

    fun new_counters(): FarmCounters
    {
        FarmCounters
        {
            harvested   : 0,
            planted     : 0,
            plots       : vector::empty<u8>(),
        }
    }

    fun plant(counters: &mut FarmCounters, plotID: u8)
    {
        let length = vector::length(&counters.plots);

        assert!(plotID >= 1 && plotID <= (MAX_PLOTS as u8), E_PLOT_INVALID_ID );

        assert!(length <  MAX_PLOTS, E_PLOT_EXC_LIMIT);

        let mut i = 0;

        while (i < length)
        {
            let existing_plot = *vector::borrow(&counters.plots, i);

            assert!(existing_plot != plotID, E_PLOT_ALREADY_EXISTS);

            i = i + 1;
        };

        vector::push_back(&mut counters.plots, plotID);

        counters.planted = counters.planted + 1;
    }

    fun harvest(counters: &mut FarmCounters, plotId: u8)
    {
        let length = vector::length(&counters.plots);

        let mut i           = 0;
        let mut found_index = length;

        while (i < length)
        {
            let existing_plot = *vector::borrow(&counters.plots, i);

            if (existing_plot == plotId)
            {
                found_index = i;
            };

            i = i + 1;
        };

        assert! (found_index < length, E_PLOT_NOT_FOUND);

        vector::remove(&mut counters.plots, found_index);

        counters.harvested = counters.harvested + 1;
    }
}

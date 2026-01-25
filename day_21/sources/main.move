module challenge::day_21
{
    use sui::event;

    #[test_only]
    use sui::test_scenario;
    #[test_only]
    use std::unit_test::assert_eq;

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

    public struct Farm has key
    {
        id       : UID,
        counters : FarmCounters,
    }

    fun new_farm(ctx: &mut TxContext): Farm
    {
        let id = object::new(ctx);

        Farm
        {
            id       : id,
            counters : new_counters(),
        }
    }

    entry fun create_farm(ctx: &mut TxContext)
    {
        let farm = new_farm     (ctx );

        transfer:: share_object (farm);
    }

    fun total_planted(farm: &Farm): u64
    {
        farm.counters.planted
    }

    fun total_harvsed(farm: &Farm): u64
    {
        farm.counters.harvested
    }

    fun plant_on_farm(farm: &mut Farm, plotId: u8)
    {
        plant   (&mut farm.counters, plotId);
    }

    fun harvs_fr_farm(farm: &mut Farm, plotId: u8)
    {
        harvest (&mut farm.counters, plotId);
    }

    entry fun plant_on_farm_entry(farm: &mut Farm, plotId: u8)
    {
        plant_on_farm(farm, plotId);

        let total_planted = total_planted(farm);

        let event = PlantEvent { planted_after: total_planted };

        event::emit(event);
    }

    entry fun harvs_fr_farm_entry(farm: &mut Farm, plotId: u8)
    {
        harvs_fr_farm(farm, plotId);
    }

    public struct PlantEvent has copy, drop
    {
        planted_after: u64,
    }

    #[test]
    fun test_create_farm()
    {
        let mut scenario = test_scenario::begin(@0x1);
        {
            create_farm(test_scenario::ctx(&mut scenario));
        };
        test_scenario::next_tx(&mut scenario, @0x1);
        {
            let farm = test_scenario::take_shared<Farm>(&scenario);

            assert_eq!(total_planted(&farm), 0);
            assert_eq!(total_harvsed(&farm), 0);

            test_scenario::return_shared(farm);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_planting_increases_counter()
    {
        let mut scenario = test_scenario::begin(@0x1);
        {
            create_farm(test_scenario::ctx(&mut scenario));
        };
        test_scenario::next_tx(&mut scenario, @0x1);
        {
            let mut farm = test_scenario::take_shared<Farm>(&scenario);

            plant_on_farm(&mut farm, 1);

            assert_eq!(total_planted(&farm), 1);
            assert_eq!(total_harvsed(&farm), 0);

            test_scenario::return_shared(farm);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_harvesting_increases_counter()
    {
        let mut scenario = test_scenario::begin(@0x1);
        {
            create_farm(test_scenario::ctx(&mut scenario));
        };
        test_scenario::next_tx(&mut scenario, @0x1);
        {
            let mut farm = test_scenario::take_shared<Farm>(&scenario);

            plant_on_farm(&mut farm, 1);
            harvs_fr_farm(&mut farm, 1);

            assert_eq!(total_planted(&farm), 1);
            assert_eq!(total_harvsed(&farm), 1);

            test_scenario::return_shared(farm);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = E_PLOT_NOT_FOUND)]
    fun test_multiple_operations()
    {
        let mut scenario = test_scenario::begin(@0x1);
        {
            create_farm(test_scenario::ctx(&mut scenario));
        };
        test_scenario::next_tx(&mut scenario, @0x1);
        {
            let mut farm = test_scenario::take_shared<Farm>(&scenario);

            plant_on_farm(&mut farm, 1);
            plant_on_farm(&mut farm, 2);
            plant_on_farm(&mut farm, 3);

            harvs_fr_farm(&mut farm, 3);
            
            assert_eq!(total_planted(&farm), 3);
            assert_eq!(total_harvsed(&farm), 1);

            test_scenario::return_shared(farm);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = E_PLOT_INVALID_ID)]
    fun test_invalid_plot_id_zero()
    {
        let mut scenario = test_scenario::begin(@0x1);
        {
            create_farm(test_scenario::ctx(&mut scenario));
        };
        test_scenario::next_tx(&mut scenario, @0x1);
        {
            let mut farm = test_scenario::take_shared<Farm>(&scenario);

            plant_on_farm(&mut farm, 0);

            test_scenario::return_shared(farm);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = E_PLOT_INVALID_ID)]
    fun test_invalid_plot_id_too_large()
    {
        let mut scenario = test_scenario::begin(@0x1);
        {
            create_farm(test_scenario::ctx(&mut scenario));
        };
        test_scenario::next_tx(&mut scenario, @0x1);
        {
            let mut farm = test_scenario::take_shared<Farm>(&scenario);

            plant_on_farm(&mut farm, 99);

            test_scenario::return_shared(farm);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = E_PLOT_ALREADY_EXISTS)]
    fun test_duplicate_plot()
    {
        let mut scenario = test_scenario::begin(@0x1);
        {
            create_farm(test_scenario::ctx(&mut scenario));
        };
        test_scenario::next_tx(&mut scenario, @0x1);
        {
            let mut farm = test_scenario::take_shared<Farm>(&scenario);

            plant_on_farm(&mut farm, 1);
            plant_on_farm(&mut farm, 1);

            test_scenario::return_shared(farm);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = E_PLOT_EXC_LIMIT)]
    fun test_plot_limit()
    {
        let mut scenario = test_scenario::begin(@0x1);
        {
            create_farm(test_scenario::ctx(&mut scenario));
        };
        test_scenario::next_tx(&mut scenario, @0x1);
        {
            let mut farm = test_scenario::take_shared<Farm>(&scenario);

            let mut i = 1;

            while (i <= 20)
            {
                plant_on_farm(&mut farm, (i as u8));

                i = i + 1;
            };
            plant_on_farm(&mut farm, 1);

            test_scenario::return_shared(farm);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = E_PLOT_NOT_FOUND)]
    fun test_harvest_nonexistent_plot()
    {
        let mut scenario = test_scenario::begin(@0x1);
        {
            create_farm(test_scenario::ctx(&mut scenario));
        };
        test_scenario::next_tx(&mut scenario, @0x1);
        {
            let mut farm = test_scenario::take_shared<Farm>(&scenario);

            harvs_fr_farm(&mut farm, 1);

            test_scenario::return_shared(farm);
        };
        test_scenario::end(scenario);
    }
}

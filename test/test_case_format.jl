using DataFrames

fname = joinpath(@__DIR__, joinpath("../cases", "bus_3.toml"))
fname_w_gencost = joinpath(@__DIR__, joinpath("../cases", "bus_3_w_gencost.toml"))

case = Case(fname)
case_w_gencost = Case(fname_w_gencost)

@test case.baseMVA == 100
@test case.gen[2, :mBase] == 100
@test get_power_injection_vector(case) == [0, 100, -100]
@test case.gencost == DataFrame()
@test get_n_buses(case) == 3

@test case_w_gencost.gencost[2, :cp1] == 1.2
    
@test get_bus(test, "1")[:type] == 3 # Check if the bus is the swing bus
@test is_load_bus(test, "7") # Check if the bus is a load bus
@test is_gen_bus(test, "1") # Check if the bus is a load bus
@test get_n_buses(test_3_bus) == 3

@test case.ref_bus == 1

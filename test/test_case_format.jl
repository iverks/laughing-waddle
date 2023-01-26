using DataFrames

fname = joinpath(@__DIR__, joinpath("../cases", "bus_3.toml"))

case = Case(fname)

@test case.baseMVA == 100
@test case.gen[2, :mBase] == 100
@test get_power_injection_vector(case) == [0, 100, -100]
@test case.gendata == DataFrame()
@test get_n_buses(case) == 3

@test get_bus(test, "1")[:type] == 3 # Check if the bus is the swing bus
@test is_load_bus(test, "7") # Check if the bus is a load bus
@test is_gen_bus(test, "1") # Check if the bus is a load bus
@test get_n_buses(test_3_bus) == 3

@test case.ref_bus == 1

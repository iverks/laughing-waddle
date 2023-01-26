using DataFrames

fname = joinpath(@__DIR__, joinpath("../cases", "bus_3.toml"))

case = Case(fname)

@test case.baseMVA == 100
@test case.gen[2, :mBase] == 100
@test get_n_buses(case) == 3

@test get_bus(test, "1")[:type] == 3 # Check if the bus is the swing bus
@test get_n_buses(test_3_bus) == 3

@test case.ref_bus == 1

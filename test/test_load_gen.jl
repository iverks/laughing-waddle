
fname = joinpath(@__DIR__, joinpath("../cases", "bus_3.toml"))

case = Case(fname)

@test is_load_bus(test, "7") # Check if the bus is a load bus
@test is_gen_bus(test, "1") # Check if the bus is a load bus
@test get_power_injection_vector(case) == [0, 100, -100]

@test get_gen_buses_power(case) == [0, 100]

@test get_gen_buses_power(case, 1) == [0, 100]
@test get_gen_buses_power(case, 2) == [0, 100]

@test get_load_buses_power(case, 1) == [100]
@test get_load_buses_power(case, 2) == [100]

@test get_power_injection_vector(case, 1) == [0, 100, -100]
@test get_power_injection_vector(case, 2) == [0, 100, -100]

@test get_power_injection_vector_pu(case, 1) == [0, 1, -1]
@test get_power_injection_vector_pu(case, 2) == [0, 1, -1]

@test get_n_os(case) == 2


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

create_random_states!(case, 1, 0.1)

@test sum(case.gendata.P) ≈ sum(case.gendata.P)

set_load_bus_idx!(case)

@test case.load[:, :bus_idx] == [3, 3]

case = Case("../cases/bus_4_grainger.toml")
Pd = -[50 + im*30.99, 170+im*105.34, 200+im*123.94, 80+im*49.58]
Pd[4] += 318
@test get_complex_power_injection_vector(case) == Pd

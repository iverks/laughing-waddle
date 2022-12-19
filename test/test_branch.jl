
case = Case(fname)
fname = joinpath(@__DIR__, joinpath("../cases", "bus_3.toml"))
@test get_line_lims_pu(case) == [0.8, 1,1]
@test get_n_lines(case) == 3
@test get_branch(test, "2", "3")[1, :x] == 0.5 # Check if the branch reactance is correct
@test get_n_lines(test_3_bus) == 3
@test is_switch(test, "4", "7")
@test ~is_switch(test, "4", "9")
@test ~is_indicator(test, "4", "7")

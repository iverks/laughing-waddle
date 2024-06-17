using Test
using SintPowerCase

case_dir = joinpath(@__DIR__, "..", "cases")
test = Case(joinpath(case_dir, "bus_6.toml"))
test_3_bus = Case(joinpath(case_dir, "bus_3.toml"))
test_4_bus = Case(joinpath(case_dir, "bus_4.toml"))

four_area = Case(joinpath(case_dir, "4area_network.toml"))

test_island = Case(joinpath(case_dir, "island_test.toml"))

# Test AC power flow matrices
y_12 = 1 / (0.042 + im * 1)
y_13 = 1 / (0.065 + im * 0.5)
y_23 = 1 / (0.025 + im * 0.75)


b_1 = im * 0.01
b_2 = im * 0.01
b_3 = im * 0.01
Y_3bus = [y_12+b_1+y_13+b_3 -y_12 -y_13;
     -y_12 y_12+b_1+y_23+b_3 -y_23;
     -y_13 -y_23 y_13+b_2+y_23+b_3]
# Test calculating the matrix from the Power system Analysis book by Grainger
# The example is on page 337 and the matrix on page 338.

Y_grainger = [8.985190-im*44.835953 -3.815629+im*19.078144 -5.169561+im*25.847809 0;
     -3.815629+im*19.078144 8.985190-im*44.835953 0 -5.169561+im*25.847809;
     -5.169561+im*25.847809 0 8.193267-im*40.863838 -3.023705+im*15.118528;
     0 -5.169561+im*25.847809 -3.023705+im*15.118528 8.193267-im*40.863838]
grainger = Case(joinpath(case_dir, "bus_4_grainger.toml"))

using LinearAlgebra
# Set up admittance matrix for dc power flow
b_12 = 1
b_13 = 2
b_23 = 4/3

# Create susceptance matrix
B = [b_12+b_13 -b_12 -b_13;
     -b_12 b_12+b_23 -b_23;
     -b_13 -b_23 b_13+b_23]

A = [1 -1 0;
     1 0 -1;
     0 1 -1]

A_4_bus = [1 -1 0 0;
		   1 0 -1 0;
		   0 1 0 -1;
		   0 0 1 -1;
		   1 0 0 -1]
	

# The object test is from set_up_simple_test_system.jl
@test size(get_incidence_matrix(four_area)) == (30, 25)
take_out_line!(test, "2")

@test A == get_incidence_matrix(test_3_bus)
@test A_4_bus == get_incidence_matrix(test_4_bus)

Y_pr = Diagonal([y_12, y_13, y_23])

@test Y_pr == get_primitive_admittance_matrix(test_3_bus)

@test isapprox(sum(Y_3bus - get_admittance_matrix(test_3_bus)), 0; atol=1e-9)

@test isapprox(sum(Y_grainger - get_admittance_matrix(grainger)), 0; atol=1e-5)

@test contingency_matrix(grainger, "1", "2") == contingency_matrix(grainger, 1)

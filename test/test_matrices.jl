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

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

# Test AC power flow matrices
y_12 = 1/(0.042 + im*1)
y_13 = 1/(0.065 + im*0.5)
y_23 = 1/(0.025 + im*0.75)


b_1 = im*0.01
b_2 = im*0.01
b_3 = im*0.01
Y_pr = Diagonal([y_12+b_1, y_13+b_2, y_23+b_3])

@test Y_pr == get_primitive_admittance_matrix(test_3_bus)

Y = [y_12+b_1+y_13+b_3 -y_12-b_2 -y_13-b_3;
     -y_12-b_1 y_12+b_1+y_23+b_3 -y_23-b_3;
     -y_13-b_2 -y_23-b_3 y_13+b_2+y_23+b_3]
@test isapprox(sum(Y- get_admittance_matrix(case)), 0; atol=1e-9)

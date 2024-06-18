include("set_up_test_cases.jl")

@testset "Test case format" begin
    include("test_case_format.jl")
end

@testset "Test branch methods" begin
    include("test_branch.jl")
end

@testset "Test methods for constructing matrices" begin
    include("test_matrices.jl")
end

@testset "Test methods for retrieving load and generator data" begin
    include("test_load_gen.jl")
end

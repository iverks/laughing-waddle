using LinearAlgebra
using SparseArrays
"""
    get_susceptance_vector(case)
    Returns the susceptance vector for performing a dc power flow.

    Inputs:
        case: The power system to get the susceptance vector for.
        consider_status: Whether or not branch in service status should be
            considered.
"""
function get_susceptance_vector(case::Case)::Array{Float64, 1}
    return map(x-> 1/x, case.branch[:, :x])
end

function get_susceptance_vector(case::Case, consider_status::Bool)::Array{Float64, 1}
	if consider_status
		return map(x-> 1/x,
				   case.branch[case.branch[!, :status], :x])
	else
		return
		get_susceptance_vector(case)
	end
end

"""
    Returns the primitive admittance matrix for a power system.
    This is a matrix with dimensions BxB where B is the number of branches.
    It is a diagonal matrix with the sum of the line and shunt impedances
    on the diagonal.
"""
function get_primitive_admittance_matrix(case::Case)::Diagonal{ComplexF64}
    return Diagonal(map(x-> 1/x,
                        case.branch[:, :r] + im*case.branch[:, :x]))
end


"""
    get_incidence_matrix(case)::Array{Float64}
    Returns the incidence matrix of a power system.
    
    Inputs:
        case: The power system to get the susceptance vector for.
        consider_status: Whether or not branch in service status should be
        considered.
"""
function get_incidence_matrix(case::Case)::SparseMatrixCSC{Int64, Int64}
	A = spzeros(Int, nrow(case.branch), nrow(case.bus))
	for (id, branch) in enumerate(eachrow(case.branch))
		A[id, get_bus_row(case, branch.f_bus)] = 1
		A[id, get_bus_row(case, branch.t_bus)] = -1
	end
	return A
end

function get_incidence_matrix(case::Case, consider_status::Bool)::SparseMatrixCSC{Int64, Int64}
	if consider_status
		return get_incidence_matrix(case)[case.branch[:, :status], :]
	else
		return get_incidence_matrix(case)
	end
end

function get_power_injection_vector_pu(case::Case)::Vector{Float64}
    get_power_injection_vector(case)/case.baseMVA
end

function get_bus_angle_vector(case::Case)
    case.bus[:, :Va]
end

"""
    get_dc_admittance_matrix(case)
    Returns the admittance matrix for performing a dc power flow.
    Inputs:
        case: The power system data.
        consider_status: If branch in service status should be considered.
"""
function get_dc_admittance_matrix(case::Case)
    A = get_incidence_matrix(case)
    return A*Diagonal(get_susceptance_vector(case))*A'
    end

function get_dc_admittance_matrix(case::Case, consider_status::Bool)
    A = get_incidence_matrix(case, consider_status)
    return A*Diagonal(get_susceptance_vector(case, consider_status))*A'
end

"""
    returns the admittance matrix of the system.
"""
function get_admittance_matrix(case::Case)::SparseMatrixCSC{ComplexF64, Int64}
    if all(case.branch.b.==0)
        return get_admittance_matrix(get_incidence_matrix(case),
                                     get_primitive_admittance_matrix(case))
    else
        Y = spzeros(ComplexF64, length(case.bus.ID), length(case.bus.ID))
        for branch in eachrow(case.branch)
            add_branch_to_admittance_matrix!(Y, case.bus.ID.==branch.f_bus, case.bus.ID.==branch.t_bus,
                                            branch.r, branch.x, branch.b)

        end
    end
    return Y
end

function add_branch_to_admittance_matrix!(Y::SparseMatrixCSC{ComplexF64, Int64},
        f_idx::BitVector, t_idx::BitVector, x::Real, r::Real, b::Real)
    Y[f_idx, f_idx] .+= 1/(r+im*x)+im*b
    Y[t_idx, t_idx] .+= 1/(r+im*x)+im*b
    Y[f_idx, t_idx] .-= 1/(r+im*x)
    Y[t_idx, f_idx] .-= 1/(r+im*x)
end

"""
    Creates a matrix that if subtracted to the admittance matrix implements a 
    contingency.
"""
function contingency_matrix(case::Case, f_bus::String, t_bus::String)
    Y = spzeros(ComplexF64, length(case.bus.ID), length(case.bus.ID))
    for branch in eachrow(case.branch[case.branch.f_bus.==f_bus, case.branch.t_bus.==t_bus])
        add_branch_to_admittance_matrix!(Y, case.bus.ID.==f_bus, case.bus.ID.==t_bus,
                                         branch.r, branch.x, branch.b)
    end

    return Y
end


"""
    Returns the incide matrix of the system as A'*Y_pr*A, where
    A is the system incidence matrix and Y_pr is the primitive
    admittance matrix.
"""
function get_admittance_matrix(A::SparseMatrixCSC{Int64, Int64},
    Y_pr::Diagonal{ComplexF64})::SparseMatrixCSC{ComplexF64, Int64}
    return A'*Y_pr*A
end

function get_complex_voltage_vector(case::Case)::Vector{ComplexF64}
    case.bus[:, :Vm].*exp.(im*case.bus[:, :Va])
end

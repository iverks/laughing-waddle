using LinearAlgebra
"""
    get_susceptance_vector(case)
    Returns the susceptance vector for performing a dc power flow.

    Inputs:
        case: The power system to get the susceptance vector for.
        consider_status: Whether or not branch in service status should be
            considered.
"""
function get_susceptance_vector(case::Case)::Array{Float64, 1}
    return map(x-> 1/x, case.branch[:,:x])
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
    get_incidence_matrix(case)::Array{Float64}
    Returns the incidence matrix of a power system.
    
    Inputs:
        case: The power system to get the susceptance vector for.
        consider_status: Whether or not branch in service status should be
        considered.
"""
function get_incidence_matrix(case::Case)::Array{Int64, 2}
	A = zeros(Int, nrow(case.branch), nrow(case.bus))
	for (id, branch) in enumerate(eachrow(case.branch))
		A[id, get_bus_row(case, branch.f_bus)] = 1
		A[id, get_bus_row(case, branch.t_bus)] = -1
	end
	return A
end

function get_incidence_matrix(case::Case, consider_status::Bool)::Array{Int64, 2}
	if consider_status
		return get_incidence_matrix(case)[case.branch[:, :status], :]
	else
		return get_incidence_matrix(case)
	end
end

function get_power_injection_vector(case::Case)::Vector{Float64}
	Pd = zeros(size(case.bus, 1))
    Pg = zeros(length(Pd))
	if isempty(case.loaddata)
		Pd = case.bus[:, :Pd]
	else
		Pd[get_load_indices(case)] = case.loaddata.Pd
	end
    Pg[get_gen_indices(case)] = get_bus_generated_power(case)
    return Pg - Pd
end

function get_power_injection_vector_pu(case::Case)::Vector{Float64}
    get_power_injection_vector(case)/case.baseMVA
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

"""
    Returns the sum of production at generator buses.
"""
function get_gen_buses_power(case::Case)
    get_all_buses_aggregated_power(case.gen)
end

"""
   Aggregates the power for generators or loads for all buses
   
   Inputs:
        df: Dataframe with either the power for all generators or loads.
"""
function get_all_buses_aggregated_power(df::DataFrame)
    combine(groupby(df, :bus), :P => sum)[!, :P_sum]
end


"""Return indices of the buses with loads."""
function get_load_indices(mpc::Case)::Vector{Bool}
	return ∈(mpc.loaddata.bus).(mpc.bus.ID)
end

"""Return indices of the buses with generators."""
function get_gen_indices(mpc::Case)::Vector{Bool}
	return ∈(mpc.gen.bus).(mpc.bus.ID)
end

"""Return indices of the buses with generators."""
function get_gen_indices(mpc::Case, os::Integer)::Vector{Bool}
	return ∈(mpc.gendata.bus).(mpc.bus.ID)
end

"""Return indices of the buses with generators."""
function get_load_indices(mpc::Case, os::Integer)::Vector{Bool}
	return ∈(mpc.loaddata.bus).(mpc.bus.ID)
end

"""
    is_load_bus(case, id::String)
    Returns true if the bus bus_id is a load.
"""
function is_load_bus(case::Case, bus_id::String)::Bool
	return any(x-> x>0, case.bus[case.bus.ID.==bus_id, :Pd])
end

"""
    Returns the power injection vector.
"""
function get_power_injection_vector(case::Case)::Vector{Float64}
	Pd = zeros(size(case.bus, 1))
    Pg = zeros(length(Pd))
    Pd = case.bus[:, :Pd]
    Pg[get_gen_indices(case)] = get_gen_buses_power(case)
    return Pg - Pd
end

"""
    Returns the power for generator buses for os
"""
function get_gen_buses_power(case::Case, os::Integer)
    get_all_buses_aggregated_power(case.gendata[case.gendata.OS.==os,:])
end

"""
    Returns the power demamd for load buses for os
"""
function get_load_buses_power(case::Case, os::Integer)
    get_all_buses_aggregated_power(case.loaddata[case.loaddata.OS.==os,:])
end

function get_power_injection_vector(case::Case, os::Integer)
	Pd = zeros(size(case.bus, 1))
    Pg = zeros(length(Pd))
    Pd[get_load_indices(case)] = get_load_buses_power(case, os)
    Pg[get_gen_indices(case, os)] = get_gen_buses_power(case, os)
    return Pg - Pd
end

function get_power_injection_vector_pu(case::Case, os::Integer)
    get_power_injection_vector(case, os)/case.baseMVA
end

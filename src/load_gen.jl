"""
    Returns the sum of production at generator buses.
"""
function get_gen_buses_power(case::Case)
    get_all_buses_aggregated_power(case.gen, :P)
end

"""
    Returns the sum of active load at load buses.
"""
function get_load_buses_power(case::Case)
    get_all_buses_aggregated_power(case.load, :P)
end

"""
    Returns the sum of reactive consumption at load buses.
"""
function get_load_buses_reactive_power(case::Case)
    get_all_buses_aggregated_power(case.load, :Q)
end


"""
   Aggregates the power for generators or loads for all buses
   
   Inputs:
        df: Dataframe with either the power for all generators or loads.
        type: Active or reactive power.
"""
function get_all_buses_aggregated_power(df::DataFrame,
    type::Symbol)
    combine(groupby(df, :bus), type => sum)[!, Symbol(string(type) * "_sum")]
end


"""Return indices of the buses with loads."""
function get_load_indices(mpc::Case)::Vector{Bool}
    if isempty(mpc.load)
        return mpc.bus.Pd .> 0
    else
        return ∈(mpc.load.bus).(mpc.bus.ID)
    end
end

"""Return indices of the buses with generators."""
function get_gen_indices(mpc::Case)::Vector{Bool}
    return ∈(mpc.gen.bus).(mpc.bus.ID)
end

"""
    is_load_bus(case, id::String)
    Returns true if the bus bus_id is a load.
"""
function is_load_bus(case::Case, bus_id::String)::Bool
    return any(x -> x > 0, case.bus[case.bus.ID.==bus_id, :Pd])
end

"""
    Returns the power injection vector.
"""
function get_power_injection_vector(case::Case)::Vector{Float64}
    Pd = zeros(size(case.bus, 1))
    Pg = zeros(length(Pd))

    Pd[get_load_indices(case)] = get_load_buses_power(case)
    Pg[get_gen_indices(case)] = get_gen_buses_power(case)
    return Pg - Pd
end

function get_complex_power_injection_vector(case::Case)
    Qd = zeros(size(case.bus, 1))
    Qd[get_load_indices(case)] = get_load_buses_reactive_power(case)
    return get_power_injection_vector(case) - im * Qd
end

function get_complex_power_injection_vector_pu(case::Case)
    get_complex_power_injection_vector(case) / case.baseMVA
end


"""
    Returns the power for generator buses for os
"""
function get_gen_buses_power(case::Case, os::Integer)
    get_all_buses_aggregated_power(case.gendata[case.gendata.OS.==os, :], :P)
end

"""
    Returns the power demamd for load buses for os
"""
function get_load_buses_power(case::Case, os::Integer)
    get_all_buses_aggregated_power(case.loaddata[case.loaddata.OS.==os, :], :P)
end

function get_power_injection_vector(case::Case, os::Integer)
    Pd = zeros(size(case.bus, 1))
    Pg = zeros(length(Pd))
    Pd[get_load_indices(case)] = get_load_buses_power(case, os)
    Pg[get_gen_indices(case)] = get_gen_buses_power(case, os)
    return Pg - Pd
end

function get_power_injection_vector_pu(case::Case, os::Integer)
    get_power_injection_vector(case, os) / case.baseMVA
end



"""
    Returns the number of oses in the case.
"""
function get_n_os(case::Case)
    length(unique(case.loaddata.OS))
end

"""
    Fills the loaddata and gendata matrices with random data.

    It generates new operating states by addding a normally distributed
    number to the load demand that is already in the case. The number is
    given as a standard deviation multiplied with the current load at the bus.
"""
function create_random_states!(case::Case, n_states::Integer, std::Real)
    n_loads = length(case.load.P)
    n_gens = length(case.gen.P)

    gendata = DataFrame(OS=repeat(1:n_states, inner=n_gens),
        ID=repeat(case.gen.ID, outer=n_states),
        bus=repeat(case.gen.bus, outer=n_states),
        P=zeros(n_states * n_gens))
    loaddata = DataFrame(OS=repeat(1:n_states, inner=n_loads),
        ID=repeat(case.load.ID, outer=n_states),
        bus=repeat(case.load.bus, outer=n_states),
        P=zeros(n_states * n_loads))
    for os = 1:n_states
        # Draw a new random load
        Pl = case.load.P .* (ones(n_loads) + std * randn(n_loads))
        loaddata[loaddata.OS.==os, :P] = Pl
        # Set total prdoction equal to total load
        Pg = sum(Pl)
        S = sum(case.gen.Pmax)
        for id in case.gen.ID
            gendata[gendata.OS.==os.&&gendata.ID.==id, :P] .= Pg * case.gen[case.gen.ID.==id, :Pmax] / S
        end
    end
    case.gendata = gendata
    case.loaddata = loaddata
end

"""
   Find the indices of the buses where the generators or loads are located

"""
function set_bus_idx!(case::Case, df::DataFrame)
    df[!, :bus_idx] = Integer.(indexin(df.bus, case.bus.ID))
end

function set_gen_bus_idx!(case::Case)
    set_bus_idx!(case, case.gen)
end

function set_load_bus_idx!(case::Case)
    set_bus_idx!(case, case.load)
end

"""
    returns the total load power at a bus.
"""
function get_load_bus_power(case::Case, bus::String)
    sum(case.load[case.load.bus.==bus, :P])
end

"""
    returns the total gen power at a bus.
"""
function get_gen_bus_power(case::Case, bus::String)
    sum(case.gen[case.gen.bus.==bus, :P])
end

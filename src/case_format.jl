using DataFrames
using CSV
using TOML

mutable struct Case
    baseMVA::Float64
    bus::DataFrame
    branch::DataFrame
    gen::DataFrame
    load::DataFrame
    switch::DataFrame
    indicator::DataFrame
    reldata::DataFrame
    loaddata::DataFrame
    transformer::DataFrame
    gendata::DataFrame
    ref_bus::Integer
end

function Case()::Case
    baseMVA = 100
    bus = DataFrame()
    branch = DataFrame()
    gen = DataFrame()
    load = DataFrame()
    switch = DataFrame()
    indicator = DataFrame()
    reldata = DataFrame()
    loaddata = DataFrame()
    transformer = DataFrame()
    gendata = DataFrame()
    ref_bus = 0
    Case(baseMVA, bus, branch, gen, load, switch, indicator, reldata, loaddata, transformer, gendata, ref_bus)
end

function Case(fname::String)::Case
    mpc = Case()
    conf = TOML.parsefile(fname)
    dir = splitdir(fname)[1]
    for (field, file) in conf["files"]
        temp = CSV.File(joinpath(dir, file), stringtype=String) |> DataFrame
        # Convert IDs to string
        for key in ["bus", "ID", "f_bus", "t_bus"]
            if key in names(temp)
                temp[!, key] = string.(temp[:, key])
            end
        end
        setfield!(mpc, Symbol(field), temp)
        # Sort everything to appear in the order of the buses
        if field in ["gen", "load", "gendata", "loaddata"]
            sort!(temp, :bus)
        end
        # Sort the buses according to their ID
        if field == "bus"
            sort!(temp, :ID)
        end

        # Make sure that values are float and not Int
        transform!(temp,
            setdiff(names(temp, Int), ["status", "type"]) .=> ByRow(Float64), renamecols=false)

    end

    # Make sure that load is in the case
    if isempty(mpc.load)
        indices = get_load_indices(mpc)
        mpc.load = DataFrame(ID=1:sum(indices),
            bus=mpc.bus.ID[indices])
        mpc.load[:, :P] = mpc.bus[indices, :Pd]
        mpc.load[:, :Q] = mpc.bus[indices, :Qd]
    end
    if "bus" ∉ names(mpc.load)
        @error "No bus column in load dataframe"
    end
    if "P" ∉ names(mpc.load)
        @warn "load dataframe found, but no load found, attemping to use bus dataframe"
        mpc.load[!, :P] = [mpc.bus[mpc.bus.ID.==load.bus, :Pd][1] for load in eachrow(mpc.load)]
    end
    if "type" ∉ names(mpc.load)
        @warn "Customer type not found."
        @warn "Assuming all loads to be residential"
        mpc.load.type .= "residential"
    end
    if "nfc" ∉ names(mpc.load)
        @warn "No information regarding non-firm connections"
        @warn "Assuming all loads to be firm connections"
        mpc.load.nfc .= false
    end

    if isempty(mpc.loaddata)
        indices = get_load_indices(mpc)
        mpc.loaddata = DataFrame(ID=1:sum(indices),
            bus=mpc.bus.ID[indices],
            OS=ones(Int, sum(indices)),
            P=mpc.bus.Pd[indices])
    end

    # 

    mpc.baseMVA = conf["configuration"]["baseMVA"]
    mpc.ref_bus = findall(mpc.bus.type .== 3)[1]
    if "external" ∉ names(mpc.gen)
        @warn "No information regarding external generators in gen."
        @warn "Assuming all generators to be non-external except slack"
        mpc.gen.external .= false
    end

    return mpc
end

function push_bus!(mpc::Case, bus::DataFrameRow)
    push!(mpc.bus, bus)
end


function push_gen!(mpc::Case, gen::DataFrameRow)
    push!(mpc.gen, gen)
end

function push_loaddata!(mpc::Case, load::DataFrameRow)
    push!(mpc.loaddata, load)
end

function get_bus(mpc::Case, ID::String)::DataFrameRow
    return mpc.bus[mpc.bus.ID.==ID, :][1, :]
end

function get_bus!(mpc::Case, ID::String)::DataFrameRow
    return mpc.bus[mpc.bus.ID.==ID, !][1, :]
end

function get_loaddata(mpc::Case, bus_id::String)::DataFrame
    return mpc.loaddata[mpc.loaddata.ID.==bus_id, :]
end

function get_gen(mpc::Case, bus_id::String)::DataFrame
    return mpc.gen[mpc.gen.ID.==bus_id, :]
end

function get_gen!(mpc::Case, bus_id::String)::DataFrame
    return mpc.gen[mpc.gen.ID.==bus_id, !]
end

function is_gen_bus(mpc::Case, bus_id::String)::Bool
    return bus_id in mpc.gen.ID
end

function delete_bus!(mpc::Case, bus::String)
    delete!(mpc.bus, mpc.bus.ID .== bus)
end

function update_ID!(mpc::Case)
    mpc.bus.ID = 1:length(mpc.bus.ID)
end

function to_csv(mpc::Case, fname::String)
    conf = Dict("files" => Dict{String,String}(),
        "configuration" => Dict{String,Any}())
    for field in fieldnames(typeof(mpc))
        df = getfield(mpc, field)
        if typeof(df) == DataFrame
            fpath = string(fname, "_", String(field), ".csv")
            conf["files"][String(field)] = fpath
            file = open(fpath, "w")
            CSV.write(file, df)
            close(file)
        end
    end
    file = open(string(fname, ".toml"), "w")
    TOML.print(file, conf)
    close(file)
end

""" Convert the case to the PYPOWER Case format."""
function to_ppc(mpc::Case)::Dict{String,Any}

    # Note: This only work if IDs are numbers, I can easily make a mapping to
    # make it work for text if needed
    case = Dict{String,Any}()

    bus = deepcopy(mpc.bus)
    bus[!, :ID] = parse.(Int, bus[!, :ID])
    case["bus"] = convert(Array{Float64,2}, bus)

    gen = deepcopy(mpc.gen)
    gen[!, :ID] = parse.(Int, gen[!, :ID])
    case["gen"] = hcat(convert(Array{Float64,2}, gen), zeros(nrow(gen), 8))

    branch = deepcopy(mpc.branch)
    branch[!, :f_bus] = parse.(Int, branch[!, :f_bus])
    branch[!, :t_bus] = parse.(Int, branch[!, :t_bus])
    case["branch"] = convert(Array{Float64,2}, branch)
    case["baseMVA"] = mpc.baseMVA
    case["version"] = 2

    return case
end

""" Returns the number of buses in the case."""
function get_n_buses(mpc::Case)::Int64
    nrow(mpc.bus)
end

""" Returns the row number of an element given by id"""
function get_id_idx(mpc::Case, elm::Symbol, id::String)::Int64
    row = findall(getfield(mpc, elm).ID .== id)
    if length(row) == 0
        error(string("Bus with ID ", repr(id), " not found."))
    elseif length(row) > 1
        error(string("Multiple buses with the ID ", repr(id)))
    else
        return row[1]
    end
end

""" Returns the row number of a bus given by id"""
function get_bus_row(mpc::Case, id::String)::Int64
    get_id_idx(mpc, :bus, id)
end



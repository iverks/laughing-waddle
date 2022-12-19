using DataFrames
using CSV
using TOML

mutable struct Case
    baseMVA::Float64
    bus::DataFrame
    branch::DataFrame
    gen::DataFrame
	switch::DataFrame
	indicator::DataFrame
	reldata::DataFrame
	loaddata::DataFrame
	transformer::DataFrame
    gencost::DataFrame
end

function Case()::Case
    baseMVA = 100
    bus = DataFrame()
    branch = DataFrame()
    gen = DataFrame()
	switch = DataFrame()
	indicator = DataFrame()
	reldata = DataFrame()
	loaddata = DataFrame()
	transformer = DataFrame()
    gencost = DataFrame()
    Case(baseMVA, bus, branch, gen, switch, indicator, reldata, loaddata, transformer, gencost)
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
	end
	mpc.baseMVA = conf["configuration"]["baseMVA"]

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
    return mpc.loaddata[mpc.loaddata.ID.==bus_id,:]
end

function get_gen(mpc::Case, bus_id::String)::DataFrame
    return mpc.gen[mpc.gen.ID.==bus_id,:]
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
	conf = Dict("files"=>Dict{String, String}(),
				"configuration"=>Dict{String, Any}())
	for field in fieldnames(typeof(mpc))
		df = getfield(mpc, field)
		if typeof(df) == DataFrame
			fpath = string(fname, "_", String(field))
			conf["files"][String(field)] = fpath
			file = open(string(fpath, ".csv"), "w")
			CSV.write(file, df)
			close(file)
		else
			conf["configuration"][String(field)] = df
		end
	end
	file = open(string(fname, ".toml"), "w")
	TOML.print(file, conf)
	close(file)
end

""" Convert the case to the PYPOWER Case format."""
function to_ppc(mpc::Case)::Dict{String, Any}

        # Note: This only work if IDs are numbers, I can easily make a mapping to
        # make it work for text if needed
	case = Dict{String, Any}()

        bus = deepcopy(mpc.bus)
        bus[!, :ID] = parse.(Int, bus[!, :ID])
	case["bus"] = convert(Array{Float64, 2}, bus)

        gen = deepcopy(mpc.gen)
        gen[!, :ID] = parse.(Int, gen[!, :ID])
	case["gen"] = hcat(convert(Array{Float64, 2}, gen), zeros(nrow(gen), 8))

        branch = deepcopy(mpc.branch)
        branch[!, :f_bus] = parse.(Int, branch[!, :f_bus])
        branch[!, :t_bus] = parse.(Int, branch[!, :t_bus])
	case["branch"] = convert(Array{Float64, 2}, branch)
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

"""Return indices of the buses with generators."""
function get_gen_indices(mpc::Case)::Vector{Bool}
	return ∈(mpc.gen.bus).(mpc.bus.ID)
end

"""Return indices of the buses with generators."""
function get_load_indices(mpc::Case)::Vector{Bool}
	return ∈(mpc.loaddata.bus).(mpc.bus.ID)
end


"""
    is_load_bus(case, id::String)
    Returns true if the bus bus_id is a load.
"""
function is_load_bus(case::Case, bus_id::String)::Bool
	return any(x-> x>0, case.bus[case.bus.ID.==bus_id, :Pd])
end

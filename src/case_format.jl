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

function push_branch_type!(df::DataFrame, f_bus::String, t_bus::String, data::DataFrameRow)
    data[:f_bus] = f_bus
    data[:t_bus] = t_bus
    push!(df, data)
end

function push_branch!(mpc::Case, f_bus::String, t_bus::String, branch::DataFrameRow)
	push_branch_type!(mpc.branch, f_bus, t_bus, branch)
end

function push_branch!(mpc::Case, type::Symbol, f_bus::String, t_bus::String, data::DataFrameRow)
	push_branch_type!(getfield(mpc, type), f_bus, t_bus, data)
end

function push_indicator!(mpc::Case, f_bus::String, t_bus::String, branch::DataFrameRow)
	push_branch_type!(mpc.indicator, f_bus, t_bus, branch)
end

function push_switch!(mpc::Case, f_bus::String, t_bus::String, branch::DataFrameRow)
	push_branch_type!(mpc.switch, f_bus, t_bus, branch)
end

function push_transformer!(mpc::Case, f_bus::String, t_bus::String, transformer::DataFrameRow)
	push_branch_type!(mpc.transformer, f_bus, t_bus, transformer)
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

function get_branch_type(branch::DataFrame, f_bus::String, t_bus::String)::DataFrame
    temp = branch[(branch.f_bus .== f_bus) .&
                      (branch.t_bus .== t_bus),:]
	if isempty(temp)
		temp = branch[(branch.t_bus .== f_bus) .&
               (branch.f_bus .== t_bus),:]
		   end
   return temp
end

function get_branch(mpc::Case, f_bus::String, t_bus::String)::DataFrame
	get_branch_type(mpc.branch, f_bus, t_bus)
end

function get_switch(mpc::Case, f_bus::String, t_bus::String)::DataFrame
	get_branch_type(mpc.switch, f_bus, t_bus)
end

function get_indicator(mpc::Case, f_bus::String, t_bus::String)::DataFrame
	get_branch_type(mpc.indicator, f_bus, t_bus)
end

function get_transformer(mpc::Case, f_bus::String, t_bus::String)::DataFrame
	get_branch_type(mpc.transformer, f_bus, t_bus)
end

function get_branch(mpc::Case, id::String)::DataFrame
    return mpc.branch[mpc.branch.ID.==id,:]
end

function is_branch_type_in_case(df::DataFrame, f_bus::String, t_bus::String)::Bool
	(any((df.f_bus .== f_bus) .& (df.t_bus .== t_bus)) ||
	 any((df.t_bus .== f_bus) .& (df.f_bus .== t_bus)))
end

function is_branch_type_in_case(mpc::Case, type::Symbol, f_bus::String,
								 t_bus::String)::Bool
	is_branch_type_in_case(getfield(mpc, type), f_bus, t_bus)
end

function set_branch_type(branch::DataFrame, f_bus::String, t_bus::String, data::DataFrame)
    branch[(branch.f_bus .== f_bus) .&
              (branch.t_bus .== t_bus), :] = data
end

function set_branch!(mpc::Case, f_bus::String, t_bus::String, data::DataFrame)
	set_branch_type(mpc.branch, f_bus, t_bus, data)
end

function set_branch_data(df::DataFrame, column::Symbol, f_bus::String, t_bus::String, data)
	df[(df.f_bus .== f_bus) .& (df.t_bus .== t_bus) .|
	  (df.f_bus .== t_bus) .& (df.t_bus .== f_bus), column] .= data
end

function set_branch_data!(mpc::Case, type::Symbol, column::Symbol, f_bus::String, t_bus::String,
				 data)
set_branch_data(getfield(mpc, type), column, f_bus, t_bus, data)
end

function set_switch!(mpc::Case, f_bus::String, t_bus::String, data::DataFrame)
	set_branch_type(mpc.switch, f_bus, t_bus, data)
end

function set_indicator!(mpc::Case, f_bus::String, t_bus::String, data::DataFrame)
	set_branch_type(mpc.indicator, f_bus, t_bus, data)
end

function is_gen_bus(mpc::Case, bus_id::String)::Bool
    return bus_id in mpc.gen.ID
end

function is_neighbor_switch_or_indicator(df::DataFrame, f_bus::String, t_bus::String)::Bool
	(any(df.f_bus .== f_bus) || any(df.t_bus .== f_bus) ||
	 any(df.f_bus .== t_bus) || any(df.t_bus .== t_bus))
end

function is_neighbor_switch(mpc::Case, f_bus::String, t_bus::String)
	nrow(mpc.switch) > 0 && is_neighbor_switch_or_indicator(mpc.switch,
															f_bus,
															t_bus)
end

function is_neighbor_indicator(mpc::Case, f_bus::String, t_bus::String)
	nrow(mpc.indicator) > 0 && is_neighbor_switch_or_indicator(mpc.indicator,
															   f_bus,
															      t_bus)
end

function is_switch(mpc::Case, f_bus::String, t_bus::String)::Bool
	nrow(mpc.switch) > 0 && is_branch_type_in_case(mpc.switch, f_bus, t_bus)
end

function is_indicator(mpc::Case, f_bus::String, t_bus::String)::Bool
	nrow(mpc.indicator) > 0 && is_branch_type_in_case(mpc.indicator, f_bus, t_bus)
end

function is_transformer(mpc::Case, f_bus::String, t_bus::String)::Bool
	nrow(mpc.transformer) > 0 && is_branch_type_in_case(mpc.transformer, f_bus, t_bus)
end

function delete_branch!(mpc::Case, f_bus::String, t_bus::String)
    deleterows!(mpc.branch, (mpc.branch.f_bus .== f_bus) .&
               mpc.branch.t_bus .== t_bus)
end

function delete_bus!(mpc::Case, bus::String)
    delete!(mpc.bus, mpc.bus.ID .== bus)
end

function get_line_lims_pu(case::Case)::Array{Float64}
    return case.branch.rateA/case.baseMVA
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

""" Returns the number of lines in the case."""
function get_n_lines(mpc::Case)::Int64
	nrow(mpc.branch)
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

""" Sets branch to out of service"""
function take_out_line!(mpc::Case, ID::String)
	if !(:status in names(mpc.branch))
		println("Status not in branch matrix, adding it.")
		 mpc.branch[!, :status] .= true
	 end
	mpc.branch[mpc.branch.ID.==ID, :status] .= false
end

""" Sets branch to out of service"""
function put_back_line!(mpc::Case, id::String)
	mpc.branch[mpc.branch.ID.==ID, :status] = true
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

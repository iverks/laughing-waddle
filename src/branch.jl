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

function get_branch_data(mpc::Case, type::Symbol, f_bus::String, t_bus::String)::DataFrame
	get_branch_type(getfield(mpc, type), f_bus, t_bus)
end

function get_branch_data(mpc::Case, type::Symbol, column::Symbol, f_bus::String, t_bus::String)
	temp = get_branch_data(mpc, type, f_bus, t_bus)
	if String(column) in names(temp)
		return temp[!, column]
	else
		return nothing
	end
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

""" Returns the number of lines in the case."""
function get_n_lines(mpc::Case)::Int64
	nrow(mpc.branch)
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

function get_line_lims_pu(case::Case)::Array{Float64}
    return case.branch.rateA/case.baseMVA
end

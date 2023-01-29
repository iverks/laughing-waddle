var documenterSearchIndex = {"docs":
[{"location":"#Documentation-for-SintPowerCase.jl","page":"Documentation for SintPowerCase.jl","title":"Documentation for SintPowerCase.jl","text":"","category":"section"},{"location":"","page":"Documentation for SintPowerCase.jl","title":"Documentation for SintPowerCase.jl","text":"This is a package intended for reading in power system data from various formats and storing it in dataframes. The dataframes should be compatible with the MATPOWER format.","category":"page"},{"location":"#Method-documentation","page":"Documentation for SintPowerCase.jl","title":"Method documentation","text":"","category":"section"},{"location":"","page":"Documentation for SintPowerCase.jl","title":"Documentation for SintPowerCase.jl","text":"Modules = [SintPowerCase]","category":"page"},{"location":"#SintPowerCase.create_random_states!-Tuple{Case, Integer, Real}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.create_random_states!","text":"Fills the loaddata and gendata matrices with random data.\n\nIt generates new operating states by addding a normally distributed\nnumber to the load demand that is already in the case. The number is\ngiven as a standard deviation multiplied with the current load at the bus.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_all_buses_aggregated_power-Tuple{DataFrames.DataFrame}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_all_buses_aggregated_power","text":"Aggregates the power for generators or loads for all buses\n\nInputs:         df: Dataframe with either the power for all generators or loads.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_bus_row-Tuple{Case, String}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_bus_row","text":"Returns the row number of a bus given by id\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_dc_admittance_matrix-Tuple{Case}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_dc_admittance_matrix","text":"get_dc_admittance_matrix(case)\nReturns the admittance matrix for performing a dc power flow.\nInputs:\n    case: The power system data.\n    consider_status: If branch in service status should be considered.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_gen_buses_power-Tuple{Case, Integer}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_gen_buses_power","text":"Returns the power for generator buses for os\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_gen_buses_power-Tuple{Case}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_gen_buses_power","text":"Returns the sum of production at generator buses.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_gen_indices-Tuple{Case}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_gen_indices","text":"Return indices of the buses with generators.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_id_idx-Tuple{Case, Symbol, String}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_id_idx","text":"Returns the row number of an element given by id\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_incidence_matrix-Tuple{Case}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_incidence_matrix","text":"get_incidence_matrix(case)::Array{Float64}\nReturns the incidence matrix of a power system.\n\nInputs:\n    case: The power system to get the susceptance vector for.\n    consider_status: Whether or not branch in service status should be\n    considered.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_load_buses_power-Tuple{Case, Integer}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_load_buses_power","text":"Returns the power demamd for load buses for os\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_load_indices-Tuple{Case}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_load_indices","text":"Return indices of the buses with loads.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_n_buses-Tuple{Case}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_n_buses","text":"Returns the number of buses in the case.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_n_lines-Tuple{Case}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_n_lines","text":"Returns the number of lines in the case.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_n_os-Tuple{Case}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_n_os","text":"Returns the number of oses in the case.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_power_injection_vector-Tuple{Case}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_power_injection_vector","text":"Returns the power injection vector.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.get_susceptance_vector-Tuple{Case}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.get_susceptance_vector","text":"get_susceptance_vector(case)\nReturns the susceptance vector for performing a dc power flow.\n\nInputs:\n    case: The power system to get the susceptance vector for.\n    consider_status: Whether or not branch in service status should be\n        considered.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.is_load_bus-Tuple{Case, String}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.is_load_bus","text":"is_load_bus(case, id::String)\nReturns true if the bus bus_id is a load.\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.put_back_line!-Tuple{Case, String}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.put_back_line!","text":"Sets branch to out of service\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.take_out_line!-Tuple{Case, String}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.take_out_line!","text":"Sets branch to out of service\n\n\n\n\n\n","category":"method"},{"location":"#SintPowerCase.to_ppc-Tuple{Case}","page":"Documentation for SintPowerCase.jl","title":"SintPowerCase.to_ppc","text":"Convert the case to the PYPOWER Case format.\n\n\n\n\n\n","category":"method"}]
}

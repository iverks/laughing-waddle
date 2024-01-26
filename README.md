# SintPowerCase.jl
This package is meant for reading power system data from different sources into data frames. The format is ispired by the MATPOWER case format. The package will also provide some power system matrices based on the data.

# Specifying input data
Input data can be specified in a .toml file. Matrices specifying data can be put in csv files. The path to the csv files are given in the `[files]` section as follows:
`[files]
bus = "bus.csv"
branch = "branch.csv"
`
The supported matrices are the fileds of the Case struct.

# Changes compared to the MATPOWER case format

## Additional load and generator matrices
In addition to defining loads in the bus matrix. It is also possible to define a load matrix in a similar way as the gen matrix used in the MATPOWER case format.

|ID|bus|customer_type|
|--|---|-------------|
|1 |1  |residential  |
|2 |1  |public       |

|ID|bus|OS|P |
|--|---|--|- |
|1 |3  |1 |50|
|2 |3  |1 |50|
|1 |3  |2 |25|
|2 |3  |2 |75|

## Storage units
The format also supports adding storage devices to the case. They are specified in the gen matrix by adding the additional columns, Emax the energy capacity and E the energy stored.

![example workflow](https://github.com/Hofsmo/SintPowerCase.jl/actions/workflows/run_tests.yaml/badge.svg)

# SintPowerCase.jl

This package is meant for reading power system data from different sources into data frames. The format is ispired by the MATPOWER case format. The package will also provide some power system matrices based on the data.

![example workflow](https://gitlab.sintef.no/power-system-asset-management/SintPowerCase.jl/badges/main/pipeline.svg)
![coverage](https://gitlab.sintef.no/power-system-asset-management/SintPowerCase.jl/badges/main/coverage.svg)
![latest release](https://gitlab.sintef.no/power-system-asset-management/SintPowerCase.jl/-/badges/release.svg)

## Documentation

Automatically generated documentation can be found at <https://power-system-asset-management.pages.sintef.no/SintPowerCase.jl>.

## Developers guide

### Pre-commit

Pre-commit runs a script before commit. In this repo we use it to make sure the formatting is proper, because otherwise we will run into issues in CI. To install `pre-commit` run

```bash
pip install pre-commit # Installs pre-commit on your system
pre-commit install # Installs the hooks defined in .pre-commit-config.yaml to your .git folder
```

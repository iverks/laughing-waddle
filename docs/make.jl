using Documenter, SintPowerCase

repo = Remotes.GitLab("gitlab.sintef.no", "power-system-asset-management", "SintPowerCase.jl")
makedocs(sitename="SintPowerCase documentation", modules=[SintPowerCase], repo=repo)

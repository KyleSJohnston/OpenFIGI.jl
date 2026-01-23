using Documenter
using OpenFIGI

DocMeta.setdocmeta!(OpenFIGI, :DocTestSetup, :(using OpenFIGI); recursive=true)

makedocs(
    sitename="OpenFIGI.jl",
    modules = [OpenFIGI],
    checkdocs = :public,
    pages = [
        "index.md",
        "start.md",
        "interface.md",
        "configuration.md",
        "mapping.md",
    ],
)

# deploydocs(
#     repo = "github.com/KyleSJohnston/OpenFIGI.jl.git",
# )

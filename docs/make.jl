using Documenter
using OpenFIGI

DocMeta.setdocmeta!(OpenFIGI, :DocTestSetup, :(using OpenFIGI); recursive=true)

makedocs(
    sitename="OpenFIGI.jl",
    modules = [OpenFIGI],
    checkdocs = :public,
)

# deploydocs(
#     repo = "github.com/KyleSJohnston/OpenFIGI.jl.git",
# )

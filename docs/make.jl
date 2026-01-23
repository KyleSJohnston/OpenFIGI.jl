using Documenter
using OpenFIGI

makedocs(
    sitename="OpenFIGI.jl",
    modules = [OpenFIGI],
    checkdocs = :public,
)

# deploydocs(
#     repo = "github.com/KyleSJohnston/OpenFIGI.jl.git",
# )

using Documenter
using FMIExchange

push!(LOAD_PATH, joinpath("..", "src"))
ENV["GKSwstype"] = "100"

srcdir = joinpath(@__DIR__, "src")
graphdir = joinpath(srcdir, "graphics")

for (root, dirs, files) in walkdir(graphdir)
    for f in filter(endswith(".ipe"), files)
        rf = f[1:end-4] * "_render.svg"
        of = f[1:end-4] * ".svg"
        if !isfile(joinpath(root, of))
            run(`iperender -svg $(joinpath(root, f)) $(joinpath(root, rf))`)
            run(`rsvg-convert --keep-aspect-ratio --zoom=1.83 -f svg $(joinpath(root, rf)) -o $(joinpath(root, of))`)
        end
    end
end

makedocs(sitename="FMIExchange.jl", 
         pages = [
             "index.md",
             "tutorial.md",
             "Defining and Simulating Models" => "Defining_and_Simulating_Models_short.md",
             "reference.md"
             ],
         )

deploydocs(repo="github.com/Electa-Git/FMIExchange.jl")

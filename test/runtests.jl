using FMIExchange
using Test
using OrdinaryDiffEq
using DiffEqCallbacks
using DelimitedFiles
using Interpolations

if !isdir(joinpath(@__DIR__, "..", "deps", "fmu"))
    @info "Compiling FMUs for native architecture"
    push!(ARGS, "native")
    include(joinpath(@__DIR__, "..", "deps", "build.jl"))
end

include("bouncingball.jl")
include("battery.jl")
include("secondorderplant.jl")

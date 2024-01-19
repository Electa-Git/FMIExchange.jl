module FMIExchange

using FMICore
using FMIImport
using SciMLBase
using DiffEqCallbacks
using Requires

import FMIImport: prepareSolveFMU, handleEvents, fmi2EnterEventMode, FMU2Event
import FMICore: fmi2True, fmi2SetContinuousStates, fmi2SetTime, fmi2SetReal, fmi2ComponentStateContinuousTimeMode, fmi2ValueReference, FMU2Solution, undual

include(joinpath(@__DIR__, "FMU.jl"))
include(joinpath(@__DIR__, "SimModel.jl"))
include(joinpath(@__DIR__, "callbacks.jl"))
include(joinpath(@__DIR__, "compose.jl"))
include(joinpath(@__DIR__, "map.jl"))

function __init__()
    @require ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210" begin
        import .ForwardDiff
        include(joinpath(@__DIR__, "ForwardDiffExtensions.jl"))
    end
end

end # module FMIExchange

export CachedFMU2

"""
    CachedFMU2{R}
    CachedFMU2(fmuloc::String, start::Real, stop::Real, ins::AbstractVector, outs::AbstractVector, staterefs::AbstractVector, parameters::Union{Dict,Nothing}=nothing)
Wrapper struct for FMU2s.
This is mainly used for dispatch purposes and ensures that the inputs, states and outputs are returned in the expected order

# Arguments
- `fmuloc::String` fmu file path
- `start::Real` simulation start time
- `stop::Real` simulation stop time
- `ins::AbstractVector` vector of fmu inputs (as string or symbol)
- `outs::AbstractVector` vector of fmu outputs (as string or symbol)
- `staterefs::AbstractVector` vector of fmu states (as string or symbol)
- `parameters::Union{Dict, Nothing}=nothing` dictionary of fmu parameters or nothing if the default parameters should be used

# Fields
- `fmu::FMU2` fmu object as defined by `FMICore.jl`
- `c::FMU2Component` fmu component object as defined by `FMICore.jl`
- `input_value_references::R` vector of non-human-readable references to the inputs (for working with the fmu)
- `output_value_references::R` vector of non-human-readable references to the outputs (for working with the fmu)
- `state_value_references::R` vector of non-human-readable references to the states (for working with the fmu)
"""
struct CachedFMU2{R}
    fmu::FMU2
    c::FMU2Component
    input_value_references::R
    output_value_references::R
    state_value_references::R
end

function CachedFMU2(
    fmuloc::String,
    start::Real,
    stop::Real,
    ins::AbstractVector,
    outs::AbstractVector,
    staterefs::AbstractVector,
    parameters::Union{Dict,Nothing}=nothing
    )
    fmu = fmi2Load(fmuloc)
    fmu.executionConfig.concat_eval = false
    fmu.executionConfig.inplace_eval = true
    fmu.handleEventIndicators = UInt64.(1:fmu.modelDescription.numberOfEventIndicators)

    # In the current version of FMIImport, this function is not type-stable, PR has been sent
    _fmustaterefs = fmi2StringToValueReference(fmu.modelDescription, String.(staterefs))
    _fmuivalrefs = fmi2StringToValueReference(fmu.modelDescription, String.(ins))
    _fmuovalrefs = fmi2StringToValueReference(fmu.modelDescription, String.(outs))
    common_type = Vector{typeintersect(typeintersect(eltype(_fmustaterefs), eltype(_fmuivalrefs)),
                                eltype(_fmuovalrefs))}
    fmustaterefs, fmuivalrefs, fmuovalrefs = convert.(common_type, (_fmustaterefs, _fmuivalrefs, _fmuovalrefs))

    c, _ = prepareSolveFMU(
        fmu,
        nothing,
        fmi2TypeModelExchange,
        nothing,
        nothing,
        nothing,
        nothing,
        nothing,
        parameters,
        start,
        stop,
        nothing; x0=nothing,
        inputs=nothing,
        handleEvents=handleEvents
    )
    fmu.hasStateEvents = fmu.modelDescription.numberOfEventIndicators > 0
    fmu.hasTimeEvents = c.eventInfo.nextEventTimeDefined == fmi2True
    return CachedFMU2(fmu, c, fmuivalrefs, fmuovalrefs, fmustaterefs)
end

function (fmu::CachedFMU2)(dx, x, u, y, t)
    fmu.c(;y=y, y_refs=fmu.output_value_references, x=x, u=u, u_refs=fmu.input_value_references, t=t)
    fmu.c(;dx=dx, x=x, u=u, u_refs=fmu.input_value_references, t=t)
end

input_size(fmu::CachedFMU2) = length(fmu.input_value_references)
state_size(fmu::CachedFMU2) = length(fmu.state_value_references)
output_size(fmu::CachedFMU2) = length(fmu.output_value_references)
md(fmu::CachedFMU2) = fmu.fmu.modelDescription
config(fmu::CachedFMU2) = fmu.fmu.executionConfig

function affectFMU!(dst, fmu::CachedFMU2, x, u, t, idx)
    affectFMU!(dst, fmu.c, x, u, t, fmu.input_value_references, idx)
    return fmu.c.eventInfo.valuesOfContinuousStatesChanged == fmi2True
end

function condition!(out, fmu::CachedFMU2, x, u, t)
    condition!(out, fmu.c, x, u, t, fmu.input_value_references)
end

function stepCompleted!(dst, fmu::CachedFMU2, x,  u, t)
    stepCompleted!(dst, fmu.c, x, u, t, fmu.input_value_references)
end

function evalFMU!(fmu::CachedFMU2, x, u, t)
    evalFMU!(fmu.c, x, u, t, fmu.input_value_references)
end

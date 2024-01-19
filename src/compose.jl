export AbstractModelSpecification, ModelSpecification, FMUSpecification, create_model, dynamics, output_callback, link_models

"""
    AbstractModelSpecification{S1,S2}
Custom type with human-readable model information which allows automatic generation of simulation models
"""
abstract type AbstractModelSpecification{S1,S2} end

"""
    usize(spec::AbstractModelSpecification)
Return the length of the state memory buffer
"""
usize(spec::AbstractModelSpecification) = length(spec.states)

"""
    psize(spec::AbstractModelSpecification)
Return the length of the io memory buffer
"""
psize(spec::AbstractModelSpecification) = length(spec.inputs) + length(spec.outputs)

"""
    create_model(::AbstractModelSpecification, uoffset=0, poffset=0; start=0.0, stop=1.0)
    create_model(specs::AbstractVector{<:AbstractModelSpecification}, uoffset=0, poffset=0; start=0.0, stop=1.0)
Return a simulation model (`<:AbstractSimModel`) with machine-readable address maps

If a vector of model specifications is provided, return a vector of simulation models with non-overlapping address maps

See also [`AbstractSimModel`](@ref)
"""
function create_model(::AbstractModelSpecification, uoffset=0, poffset=0; start=0.0, stop=1.0) end

function create_model(specs::AbstractVector{<:AbstractModelSpecification}, uoffset=0, poffset=0; start=0.0, stop=1.0)
    models = AbstractSimModel[]
    for spec in specs
        model = create_model(spec, uoffset, poffset; start=start, stop=stop)
        uoffset += usize(spec)
        poffset += psize(spec)
        push!(models, model)
    end
    return models
end

"""
    ModelSpecification{S1,S2,F,G} <: AbstractModelSpecification{S1,S2}

# Fields
- `inputs::AbstractVector{S1}`: Vector of human-readable input names
- `outputs::AbstractVector{S1}`: Vector of human-readable output names
- `states::AbstractVector{S2}`: Vector of human-readable state names
- `dynamics::F`: Function for calculating the derivative (refer to `DifferentialEquations.jl`)
- `output::G`: Function for calculating the output. This function is called as follows `output(out, state, in, time)` and should mutate the `out` variable 

See also [`SimModel`](@ref)
"""
struct ModelSpecification{S1,S2,F,G} <: AbstractModelSpecification{S1,S2}
    inputs::AbstractVector{S1}
    outputs::AbstractVector{S1}
    states::AbstractVector{S2}
    dynamics::F
    output::G
end

function create_model(spec::ModelSpecification, uoffset=0, poffset=0; start=0.0, stop=1.0)
    SimModel(spec.dynamics, spec.output, length(spec.inputs), length(spec.outputs), length(spec.states), SciMLBase.DECallback[]; ioffset=poffset, xoffset=uoffset)
end

"""
    FMUSpecification{S1, S2, S3<:Union{Symbol,AbstractString}, P<:Union{Dict{String,Float64},Nothing}} <: AbstractModelSpecification{S1,S2}
A model specification that can be converted to a `CachedModel{<:CachedFMU2}`

# Fields
- `inputs::AbstractVector{S1}`: Vector of human-readable input names
- `outputs::AbstractVector{S1}`: Vector of human-readable output names
- `states::AbstractVector{S2}`: Vector of human-readable state names
- `fmu_location::S3`: Path to the FMU
- `parameters::P`: Dictionary with FMU parameters (or nothing to use defaults)
"""
struct FMUSpecification{S1, S2, S3<:Union{Symbol,AbstractString}, P<:Union{Dict{String,Float64},Nothing}} <: AbstractModelSpecification{S1,S2}
    inputs::AbstractVector{S1}
    outputs::AbstractVector{S1}
    states::AbstractVector{S2}
    fmu_location::S3
    parameters::P
end

function create_model(spec::FMUSpecification, uoffset=0, poffset=0; start=0.0, stop=1.0)
    CachedModel(CachedFMU2(spec.fmu_location, start, stop, spec.inputs, spec.outputs, spec.states, spec.parameters), uoffset, poffset)
end

"""
    dynamics(models)
Return a single `DifferentialEquations.jl`-compatible function that calculates derivatives of all models in `models`
"""
function dynamics(models)
    f(u, p, t) = mapreduce(x->x(u, p, t), vcat, models)
    f(du, u, p, t) = map(x->x(du, u, p, t), models)
    return f
end

output!(models::AbstractVector, u, p, t) = map(x->x(u, p, t), models)

"""
    link_models(src, dst)
    link_models(src, dst, iomap)
Return a FunctionCallingCallback that connects inputs and outputs of models. This does not automatically resolve algebraic loops!

# Arguments
- `src` human-readable strings/symbols or machine-readable indices of the model io that will be copied
- `dst` human-readable strings/symbols or machine-readable indices of the copy destinations
- `iomap` dictionary mapping the human-readable strings/symbols to indices (if src and dst provided as string/symbol)
"""
function link_models(src, dst)
    FunctionCallingCallback(func_everystep=true, func_start=true) do _, _, integrator
        integrator.p[dst] = integrator.p[src]
    end
end

function link_models(src::AbstractVector, dst::AbstractVector, iomap)
    link_models(getindex.((iomap,), src), getindex.((iomap,), dst))
end

link_models(src, dst, iomap) = link_models(getindex(iomap, src), getindex(iomap, dst))

"""
    output_callback(m::AbstractSimModel)
    output_callback(ms::AbstractVector{<:AbstractSimModel})
Return a callback that calls the output function of the simulation model `m` (or every simulation model in `ms`) after every integration step
"""
function output_callback(m::AbstractSimModel)
    FunctionCallingCallback((_,_,integrator) -> output!(m, integrator.u, integrator.p, integrator.t))
end

function output_callback(ms::AbstractVector{<:AbstractSimModel})
    FunctionCallingCallback((_,_,integrator) -> for m in ms
                                output!(m, integrator.u, integrator.p, integrator.t)
                            end)
end

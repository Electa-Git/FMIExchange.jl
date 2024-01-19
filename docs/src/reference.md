# Reference
## FMU-specific functions
FMIExchange.jl currently supports only FMI version 2.0.
FMIExchange.jl automatically generates the callbacks required for handling all FMU events.
To simulate the FMU, a `CachedFMU2` must be wrapped in a `CachedModel` (See [Simulation Models](@ref))
```@docs
CachedFMU2
FMIExchange.affectFMU!(model::CachedModel{<:CachedFMU2}, integrator, idx)
FMIExchange.condition!(model::CachedModel{<:CachedFMU2}, x, t, integrator)
FMIExchange.get_time_callbacks
FMIExchange.get_state_callbacks
FMIExchange.get_step_callbacks
FMIExchange.get_input_callbacks
```

## Simulation Models
Simulation models can be directly simulated with [DifferentialEquations.jl](https://docs.sciml.ai/DiffEqDocs/stable/) like one normally would.
They contain machine-readable address maps which allow to easily combine multiple simulation models in one simulation.
```@docs
AbstractSimModel
SimModel
CachedModel
(AbstractSimModel)(u, p, t)
output!(::AbstractSimModel, u, p, t)
get_callbacks(::AbstractSimModel, start, stop)
```

## Model Specifications
Model specifications contain human-readable address maps, and can be converted to simulation models for simulation.
```@docs
AbstractModelSpecification
ModelSpecification
FMUSpecification
FMIExchange.usize(spec::AbstractModelSpecification)
FMIExchange.psize(spec::AbstractModelSpecification)
create_model(::AbstractModelSpecification, uoffset=0, poffset=0; start=0.0, stop=1.0)
```

## Simulation composition functionality
Below functions are meant to simplify composing complex simulations with multiple models.
```@docs
address_map(names, indices::AbstractVector{<:Integer})
link_models(src, dst)
output_callback(m::AbstractSimModel)
dynamics(models)
```

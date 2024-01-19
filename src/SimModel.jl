import Base.push!
export AbstractSimModel, SimModel, CachedModel, output!

"""
    AbstractSimModel
Simulation model that can be directly simulated using `DifferentialEquations.jl`.
An `AbstractSimModel` wraps an ODE with events such that it can be
easily used in a simulation with multiple components.

# Usage
A simulation model contains a number of inputs, states and outputs.
States are subject to an ODE with events.
Outputs can be calculated from the inputs and states of the model, but
this calculation may not modify the state of the model.
"""
abstract type AbstractSimModel end

iidx(s::AbstractSimModel) = s.iidx
oidx(s::AbstractSimModel) = s.oidx
xidx(s::AbstractSimModel) = s.xidx

"""
    (::AbstractSimModel)(u, p, t)
    (::AbstractSimModel)(du, u, p, t)
Calculate the derivative of the model state.
Refer to the documentation of `DifferentialEquations.jl`
"""
function (::AbstractSimModel)(u, p, t) end
function (::AbstractSimModel)(du, u, p, t) end

"""
    output!(::AbstractSimModel, u, p, t)
Write the model output to the relevant indices of `p`
"""
function output!(::AbstractSimModel, u, p, t) end

"""
    get_callbacks(model::AbstractSimModel, start, stop)
Return a vector of callbacks associated with the simulation model.

# Arguments
- `model::AbstractSimModel` simulation model
- `start` simulation start time
- `stop` simulation stop time
"""
function get_callbacks(::AbstractSimModel, start, stop) end

Base.push!(model::AbstractSimModel, cb) = push!(get_callbacks(model), cb)

"""
    SimModel <: AbstractSimModel
    SimModel(f, g, ilength::Integer, olength::Integer, xlength::Integer, cbs; ioffset = 0, xoffset = 0)
Return a basic simulation model

# Arguments
- `f`: function for calculating the derivative (refer to `DifferentialEquations.jl`)
- `g`: function for calculating the output. This function is called as follows `g(out, state, in, time)` and should mutate the `out` variable 
- `ilength`: length of the model input
- `olength`: length of the model output
- `xlength`: length of the model state
- `cbs`: callbacks associated with the model
- `ioffset=0`: io memory buffer address offset
- `xoffset=0`: state memory buffer address offset
"""
struct SimModel{F,G,I,C} <: AbstractSimModel
    f::F
    g::G
    iidx::I
    oidx::I
    xidx::I
    cbs::C
end
function SimModel(f, g, ilength::Integer, olength::Integer, xlength::Integer, cbs; ioffset = 0, xoffset = 0)
    iidx = (ioffset+1):(ioffset+ilength)
    oidx = (ioffset+ilength+1):(ioffset+ilength+olength)
    xidx = (xoffset+1):(xoffset+xlength)
    SimModel(f, g, iidx, oidx, xidx, cbs)
end

(s::SimModel)(u, p, t) = s.f(@view(u[s.xidx]), @view(p[s.iidx]), t)
(s::SimModel)(du, u, p, t) = s.f(@view(du[s.xidx]), @view(u[s.xidx]), @view(p[s.iidx]), t)
output!(s::SimModel, u, p, t) = s.g(@view(p[s.oidx]), @view(u[s.xidx]), @view(p[s.iidx]), t)
get_callbacks(s::SimModel) = s.cbs
get_callbacks(s::SimModel, _, _) = get_callbacks(s)

"""
    CachedModel <: AbstractSimModel
    CachedModel(fmu::CachedFMU2, uoffset=0, poffset=0)
Simulation model that contains caches for storing the state and input/output.

This is primarily used to accelerate FMUs: C-calls to the FMU cannot
operate on array views. If a standard `SimModel` were used, every
C-call to the FMU would thus convert that view to a new array,
allocating memory and massively slowing down the simulation.  This
struct preallocates fixed-size caches of types which can be directly
passed to C-calls and do not need to be converted.
"""
struct CachedModel{F,X,U,Y,O,I,C} <: AbstractSimModel
    f::F
    x::X
    dx::X
    u::U
    y::Y
    out::O
    dout::O
    iidx::I
    oidx::I
    xidx::I
    cbs::C
end

function CachedModel(fmu::CachedFMU2, uoffset=0, poffset=0)
    lx, lu, ly = state_size(fmu), input_size(fmu), output_size(fmu)
    x = zeros(lx)
    dx = zeros(lx)
    u = zeros(lu)
    y = zeros(ly)
    out = zeros(md(fmu).numberOfEventIndicators)
    iidx = (poffset+1):(poffset+lu)
    oidx = (poffset+lu+1):(poffset+lu+ly)
    xidx = (uoffset+1):(uoffset+lx)
    CachedModel(fmu, x, dx, u, y, out, copy(out), iidx, oidx, xidx, SciMLBase.DECallback[])
end

"""
    cache!(cm::CachedModel, u, p)
Store the relevant parts of the state and io memory buffers in the cache
"""
function cache!(cm::CachedModel, u, p)
    isempty(cm.iidx) || copyto!(cm.u, eachindex(cm.u), p, cm.iidx)
    isempty(cm.xidx) || copyto!(cm.x, eachindex(cm.x), u, cm.xidx)
end

output!(cm::CachedModel, u, p, t) = (cm(u, p, t); isempty(cm.oidx) || copyto!(p, cm.oidx, cm.y, eachindex(cm.y)))
get_callbacks(cm::CachedModel) = cm.cbs

"""
    derivative!(cm::CachedModel, dst)
Copy the cached derivative in `cm` to the destination
"""
derivative!(cm::CachedModel, du) = isempty(cm.xidx) || copyto!(du, cm.xidx, cm.dx, eachindex(cm.dx))

"""
    uncache!(cm::CachedModel, dst)
Copy the cache new state in `cm` to the destination

This is used in event handling where the state is discontinuous.
In these cases the cache for the derivative is used to store the new state.
Thus this method is an alias for `derivative!`
"""
uncache!(cm::CachedModel, dst) = derivative!(cm, dst) # simply an alias


"""
    indicators!(dst, cm::CachedModel)
Copy event indicators from `cm` to the destination
"""
indicators!(dst, cm::CachedModel) = isempty(cm.out) || copyto!(dst, cm.out)

"""
    indicators!(cm::CachedModel, src)
Copy event indicators from the source to the relevant cache in `cm`
"""
indicators!(cm::CachedModel, src) = isempty(src) || copyto!(cm.out, src)

function (cm::CachedModel)(u, p, t)
    cache!(cm, u, p)
    cm.f(cm.dx, cm.x, cm.u, cm.y, t)
    return copy(cm.dx)
end

function (cm::CachedModel)(du, u, p, t)
    cache!(cm, u, p)
    cm.f(cm.dx, cm.x, cm.u, cm.y, t)
    derivative!(cm, du)
end

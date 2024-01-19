# This portion of the package reuses code from FMI.jl (v0.11.2).
# FMI.jl is available under an MIT license.
# See LICENSE file in the FMI.jl project root for details.
# https://github.com/ThummeTo/FMI.jl/blob/v0.11.2/LICENSE

# The BSD 3-Clause License applies to the modifications made.
# Copyright (c) 2024 KU LEUVEN 
# See LICENSE file in the FMIExchange.jl project root for details

function evalFMU!(c::FMU2Component, u::Vector{fmi2Real}, p::Vector{fmi2Real}, t::Real, input_refs::AbstractVector{fmi2ValueReference})
    @assert c.state == fmi2ComponentStateContinuousTimeMode "evalFMU!(...): Must be called in mode continuous time."
    fmi2SetContinuousStates(c, copy(u); force=true)
    fmi2SetTime(c, t; force=true)
    isnothing(p) || isempty(p) || fmi2SetReal(c, input_refs, p)
    fmi2CompletedIntegratorStep(c, fmi2True) 
    fmi2EnterEventMode(c)
    handleEvents(c)
end

"""
    affectFMU!(model::CachedModel{<:CachedFMU2}, integrator, idx)
Handle events in the FMU
"""
function affectFMU!(model::CachedModel{<:CachedFMU2}, integrator, idx)
    cache!(model, integrator.u, integrator.p)
    state_changed = affectFMU!(model.dx, model.f, model.x, model.u, integrator.t, idx)
    if state_changed
        uncache!(model, integrator.u)
        u_modified!(integrator, true)
    else
        u_modified!(integrator, false)
    end
    return nothing
end

function affectFMU!(dst::Vector{fmi2Real}, c::FMU2Component, x::Vector{fmi2Real}, u::Vector{fmi2Real}, t, input_refs::AbstractArray{fmi2ValueReference}, idx)
    evalFMU!(c, x, u, t, input_refs)
    if c.eventInfo.valuesOfContinuousStatesChanged == fmi2True
        fmi2GetContinuousStates!(c, dst, UInt64(length(dst)))
    else
        copyto!(dst, x)
    end
    if idx != -1 # -1 no event, 0, time event, >=1 state event with indicator
        push!(c.solution.events, FMU2Event(t, UInt64(idx), copy(x), copy(dst)))
    end
    return nothing
end

function condition!(
    out::Vector{fmi2Real},
    c::FMU2Component,
    x::Vector{fmi2Real},
    u::Vector{fmi2Real},
    t::fmi2Real,
    input_refs,
    )
    @assert c.state == fmi2ComponentStateContinuousTimeMode "condition(...): Must be called in mode continuous time."
    c.solution.evals_condition += 1
    fmi2SetContinuousStates(c, x)
    fmi2SetTime(c, t)
    isempty(input_refs) || fmi2SetReal(c, input_refs, u)
    fmi2GetEventIndicators!(c, out)
    return nothing
end

function stepCompleted!(model::CachedModel{<:CachedFMU2}, integrator)
    c = model.f.c
    @assert c.state == fmi2ComponentStateContinuousTimeMode "stepCompleted(...): Must be in continuous time mode."
    (_, enterEventMode, terminateSimulation) = fmi2CompletedIntegratorStep(c, fmi2True)
    if terminateSimulation == fmi2True
        @error "stepCompleted(...): FMU requested termination!"
    end
    if enterEventMode == fmi2True
        affectFMU!(model, integrator, -1)
    else
        fmi2SetReal(c, model.f.input_value_references, model.u)
    end
    return nothing
end

function time_choice(c::FMU2Component, start, stop)
    c.solution.evals_timechoice += 1
    if c.eventInfo.nextEventTimeDefined == fmi2True && c.eventInfo.nextEventTime >= start && c.eventInfo.nextEventTime <= stop
            return c.eventInfo.nextEventTime
    else
        return nothing
    end
end

"""
    get_time_callbacks(model::CachedModel{<:CachedFMU2}, start, stop)
Return a callback to handle all time events in the FMU
"""
function get_time_callbacks(model::CachedModel{<:CachedFMU2}, start, stop)
    return IterativeCallback(
        (integrator) -> time_choice(model.f.c, start, stop),
        (integrator) -> affectFMU!(model, integrator, 0),
        initial_affect = (model.f.c.eventInfo.nextEventTime == start),
        save_positions=(true,true)
    )
end

"""
    get_state_callbacks(model::CachedModel{<:CachedFMU2})
Return a callback to handle state events in an FMU.

The returned callback is a continuous callback is able to detect events due to changes in the FMU state, but it will not be able to detect events due to changes in the FMU input.

See also [`get_input_callbacks`](@ref)
"""
function get_state_callbacks(model::CachedModel{<:CachedFMU2})
    return VectorContinuousCallback(
        (out, x, t, integrator) -> condition!(out, model, x, t, integrator),
        (integrator, idx) -> affectFMU!(model, integrator, idx),
        Int64(md(model.f).numberOfEventIndicators);
        rootfind = SciMLBase.RightRootFind,
        save_positions=(true,true),
        interp_points=config(model.f).rootSearchInterpolationPoints
    )
end

"""
    get_step_callbacks(model::CachedModel{<:CachedFMU2})
Return a callback to handle integrator step completion in the FMU
"""
function get_step_callbacks(model::CachedModel{<:CachedFMU2})
    return FunctionCallingCallback(
        (_, _, integrator) -> stepCompleted!(model, integrator);
        func_everystep = true,
        func_start = true)
end

function get_callbacks(model::CachedModel{<:CachedFMU2}, start, stop)
    fmu = model.f.fmu
    handle_time_callbacks  = fmu.hasTimeEvents && fmu.executionConfig.handleTimeEvents 
    handle_state_callbacks = fmu.hasStateEvents && fmu.executionConfig.handleStateEvents 
    handle_step_callbacks  = fmu.hasStateEvents || fmu.hasTimeEvents
    handle_input_callbacks = handle_state_callbacks

    cbs = SciMLBase.DECallback[]
    handle_time_callbacks  && push!(cbs, get_time_callbacks(model, start, stop))
    handle_state_callbacks && push!(cbs, get_state_callbacks(model))
    handle_step_callbacks  && push!(cbs, get_step_callbacks(model))
    handle_input_callbacks && push!(cbs, get_input_callbacks(model))
    return cbs
end

export get_callbacks

include("callbacks_fmijl.jl")

"""
    condition!(model::CachedModel{<:CachedFMU2}, x, t, integrator)
    condition!(out, model::CachedModel{<:CachedFMU2}, x, t, integrator)
Return event indicators `out` for the FMU (non-mutating and mutating version)
"""
function condition!(model::CachedModel{<:CachedFMU2}, x, t, integrator)
    cache!(model, x, integrator.p)
    condition!(model.out, model.f, model.x, model.u, t)
    return model.out
end

function condition!(out, model::CachedModel{<:CachedFMU2}, x, t, integrator)
    cache!(model, x, integrator.p)
    indicators!(model, out)
    condition!(model.out, model.f, model.x, model.u, t)
    indicators!(out, model)
    return nothing
end

"""
    get_input_callbacks(model::CachedModel{<:CachedFMU2})
Return a callback to handle state events in an FMU.

The returned callback is a discrete callback will be able to detect events due to changes in the FMU input, but it  will not be able to detect events due to changes in the FMU state.

See also [`get_state_callbacks`](@ref)
"""
function get_input_callbacks(model::CachedModel{<:CachedFMU2})
    return DiscreteCallback(
        (u, t, integrator) -> any(sign.(model.dout) .!= sign.(condition!(model, u, t, integrator))),
        (integrator) -> begin
            for idx in findall(sign.(model.dout) .!= sign.(condition!(model, integrator.u, integrator.t, integrator)))
                affectFMU!(model, integrator, idx)
            end
            copyto!(model.dout, model.out)
        end
    )
end

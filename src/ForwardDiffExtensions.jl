
evalFMU!(c::FMU2Component, u::Vector{D}, p::Vector{fmi2Real}, t::Real, input_refs::AbstractVector{fmi2ValueReference}) where {D<:ForwardDiff.Dual} = evalFMU!(c, undual(u), p, t, input_refs)
evalFMU!(c::FMU2Component, u::Vector{T}, p::Vector{D}, t::Real, input_refs::AbstractVector{fmi2ValueReference}) where {T, D<:ForwardDiff.Dual} = evalFMU!(c, u, undual(p), t, input_refs)
evalFMU!(c::FMU2Component, u::Vector{T}, p::Vector{T}, t::D, input_refs::AbstractVector{fmi2ValueReference}) where {T, D<:ForwardDiff.Dual} = evalFMU!(c, u, p, undual(t), input_refs)
evalFMU!(c::FMU2Component, u::Vector{fmi2Real}, p::Vector{fmi2Real}, t::D, input_refs::AbstractVector{fmi2ValueReference}) where {D<:ForwardDiff.Dual} = evalFMU!(c, u, p, undual(t), input_refs)

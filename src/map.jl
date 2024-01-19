export address_map

"""
    address_map(ins, outs, states, m::AbstractSimModel)
    address_map(spec::AbstractModelSpecification, uoffset=0, poffset=0)
    address_map(specs::AbstractVector{<:AbstractModelSpecification}, uoffset=0, poffset=0)
Return two dictionaries linking human-readable strings/symbols for model inputs/outputs and states to machine-readable indices
"""
address_map(names, indices::AbstractVector{<:Integer}) = Dict(names .=> indices)
address_map(names, offset::Integer=0) = Dict(names .=> (offset+1):(offset+length(names)))

function address_map(ins, outs, states, m::AbstractSimModel)
    iomap = merge(address_map(ins, iidx(m)), address_map(outs, oidx(m)))
    statemap = address_map(states, xidx(m))
    return iomap, statemap
end

function address_map(spec::AbstractModelSpecification, uoffset=0, poffset=0)
    iomap = merge(address_map(spec.inputs, poffset), address_map(spec.outputs, poffset+length(spec.inputs)))
    statemap = address_map(spec.states, uoffset)
    return iomap, statemap
end

function address_map(specs::AbstractVector{<:AbstractModelSpecification}, uoffset=0, poffset=0)
    iomap = Dict()
    statemap = Dict()
    for spec in specs
        (_iomap, _statemap) = address_map(spec, uoffset, poffset)
        uoffset += length(spec.states)
        poffset += length(spec.inputs) + length(spec.outputs)
        merge!(iomap, _iomap)
        merge!(statemap, _statemap)
    end
    return iomap, statemap
end

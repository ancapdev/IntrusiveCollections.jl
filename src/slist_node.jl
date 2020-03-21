mutable struct IntrusiveSListNode{T}
    value::T
    next::IntrusiveSListNode{T}

    function IntrusiveSListNode{T}(value::T) where {T}
        x = new{T}(value)
        x.next = x
        x
    end
end

IntrusiveSListNode(value::T) where {T} = IntrusiveSListNode{T}(value)

Base.show(io::IO, x::IntrusiveSListNode) = show(io, x.value)

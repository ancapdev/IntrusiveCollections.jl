mutable struct IntrusiveListNode{T}
    value::T
    next::IntrusiveListNode{T}
    prev::IntrusiveListNode{T}

    function IntrusiveListNode{T}(value::T) where {T}
        x = new{T}(value)
        x.next = x
        x.prev = x
        x
    end
end

IntrusiveListNode(value::T) where {T} = IntrusiveListNode{T}(value)

Base.show(io::IO, x::IntrusiveListNode) = show(io, x.value)

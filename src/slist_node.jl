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

@inline getnext(x::IntrusiveSListNode) = x.next
@inline setnext!(x::IntrusiveSListNode{T}, next::IntrusiveSListNode{T}) where {T} = x.next = next

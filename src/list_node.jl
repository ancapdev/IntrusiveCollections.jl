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

@inline getnext(x::IntrusiveListNode) = x.next
@inline getprev(x::IntrusiveListNode) = x.prev
@inline setnext!(x::IntrusiveListNode{T}, next::IntrusiveListNode{T}) where {T} = x.next = next
@inline setprev!(x::IntrusiveListNode{T}, prev::IntrusiveListNode{T}) where {T} = x.prev = prev

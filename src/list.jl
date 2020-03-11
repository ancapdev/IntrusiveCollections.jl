mutable struct IntrusiveListNode{T}
    next::Union{IntrusiveListNode{T}, Nothing}
    prev::Union{IntrusiveListNode{T}, Nothing}
    value::T
    IntrusiveListNode{T}(value::T) where {T} = new{T}(nothing, nothing, value)
    IntrusiveListNode(value::T) where {T} = new{T}(nothing, nothing, value)
end

@inline getnext(x::IntrusiveListNode, tag::Symbol) = x.next
@inline getprev(x::IntrusiveListNode, tag::Symbol) = x.prev
@inline setnext!(x::IntrusiveListNode{T}, next::Union{IntrusiveListNode{T}, Nothing}, tag::Symbol) where {T} = x.next = next
@inline setprev!(x::IntrusiveListNode{T}, prev::Union{IntrusiveListNode{T}, Nothing}, tag::Symbol) where {T} = x.prev = prev

# TODO: constant time first and last
# TODO: iterators
# TODO: show(), print like vector, in compact: only first n elements
mutable struct TaggedIntrusiveList{T, Tag}
    root::Union{T, Nothing}
end

const IntrusiveList{T} = TaggedIntrusiveList{T, :default}

@inline Base.isempty(list::TaggedIntrusiveList) = isnothing(list.root)

function Base.pushfirst!(list::TaggedIntrusiveList{T, Tag}, node::T) where {T, Tag}
    if isempty(list)
        setnext!(node, node, Tag)
        setprev!(node, node, Tag)
    else
        root = list.root::T
        tail = getprev(root, Tag)::T
        setnext!(tail, node, Tag)
        setprev!(node, tail, Tag)
        setnext!(node, root, Tag)
        setprev!(root, node, Tag)
    end
    list.root = node
    list
end

function Base.popfirst!(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    isempty(list) && throw(ArgumentError("list must be non-empty"))
    x = list.root::T
    next = getnext(x, Tag)::T
    if next === x
        list.root = nothing
    else
        prev = getprev(x, Tag)::T
        setprev!(next, prev, Tag)
        setnext!(prev, next, Tag)
        list.root = next
    end
    x
end

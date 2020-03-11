mutable struct IntrusiveListNode{T}
    next::Union{IntrusiveListNode{T}, Nothing}
    prev::Union{IntrusiveListNode{T}, Nothing}
    value::T
    IntrusiveListNode{T}(value::T) where {T} = new{T}(nothing, nothing, value)
    IntrusiveListNode(value::T) where {T} = new{T}(nothing, nothing, value)
end

getnext(x::IntrusiveListNode, tag::Symbol) = x.next
getprev(x::IntrusiveListNode, tag::Symbol) = x.prev
setnext!(x::IntrusiveListNode{T}, next::Union{IntrusiveListNode{T}, Nothing}, tag::Symbol) where {T} = x.next = next
setprev!(x::IntrusiveListNode{T}, prev::Union{IntrusiveListNode{T}, Nothing}, tag::Symbol) where {T} = x.prev = prev

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
        tail = getprev(list.root, Tag)
        setnext!(tail, node, Tag)
        setprev!(node, tail, Tag)
        setnext!(node, list.root, Tag)
        setprev!(list.root, node, Tag)
    end
    list.root = node
    list
end

function Base.popfirst!(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    isempty(list) && throw(ArgumentError("list must be non-empty"))
    x = list.root::T
    next = getnext(x, Tag)
    if next === x
        list.root = nothing
    else
        prev = getprev(x, Tag)
        setprev!(next, prev, Tag)
        setnext!(prev, next, Tag)
        list.root = next
    end
    x
end

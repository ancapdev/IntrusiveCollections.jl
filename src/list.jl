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

# TODO: could make more optimised variant with user provided null sentinel
#       using same type as node, making all code type stable.
#       User provides:
#       - niltype(::Type{NodeType})
#       - nil(::Type{NodeType}) --- or isnothing(x) and conversion from Nothing
#       Unfortunately must also provide niltype in list type instantiation
#       since parameters can't be computed
#
# TODO: constant time first and last
# TODO: show(), print like vector, in compact: only first n elements
mutable struct TaggedIntrusiveList{T, Tag}
    root::Union{T, Nothing}
    TaggedIntrusiveList{T, Tag}() where {T, Tag} = new(nothing)
end

const IntrusiveList{T} = TaggedIntrusiveList{T, :default}

Base.eltype(::Type{TaggedIntrusiveList{T, Tag}}) where {T, Tag} = T

@inline Base.isempty(list::TaggedIntrusiveList) = isnothing(list.root)
@inline Base.empty!(list::TaggedIntrusiveList) = list.root = nothing

function Base.length(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    c = 0
    for n in list
        c += 1
    end
    c
end

@inline function Base.iterate(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    isempty(list) && return nothing
    root = list.root::T
    (root, root)
end

@inline function Base.iterate(list::TaggedIntrusiveList{T, Tag}, state::T) where {T, Tag}
    x = getnext(state, Tag)::T
    x === list.root ? nothing : (x, x)
end

function Base.push!(list::TaggedIntrusiveList{T, Tag}, node::T) where {T, Tag}

end

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

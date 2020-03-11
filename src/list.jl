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

@inline getnext(x::IntrusiveListNode, tag::Symbol) = x.next
@inline getprev(x::IntrusiveListNode, tag::Symbol) = x.prev
@inline setnext!(x::IntrusiveListNode{T}, next::IntrusiveListNode{T}, tag::Symbol) where {T} = x.next = next
@inline setprev!(x::IntrusiveListNode{T}, prev::IntrusiveListNode{T}, tag::Symbol) where {T} = x.prev = prev

@inline function setnextprevself!(x, tag::Symbol)
    setnext!(x, x, tag)
    setprev!(x, x, tag)
    nothing
end

@inline function circlist_link_before!(x::T, node::T, tag::Symbol) where {T}
    prev = getprev(x, tag)::T
    setnext!(prev, node, tag)
    setprev!(node, prev, tag)
    setnext!(node, x, tag)
    setprev!(x, node, tag)
    nothing
end

@inline function circlist_unlink!(x::T, tag::Symbol) where {T}
    prev = getprev(x, tag)::T
    next = getnext(x, tag)::T
    setnext!(prev, next, tag)
    setprev!(next, prev, tag)
    next
end

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
    if isempty(list)
        setnextprevself!(node, Tag)
        list.root = node
    else
        circlist_link_before!(list.root::T, node, Tag)
    end
    list
end

function Base.pop!(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    isempty(list) && throw(ArgumentError("list must be non-empty"))
    root = list.root::T
    tail = getprev(root, Tag)::T
    if circlist_unlink!(tail, Tag) === tail
        list.root = nothing
    end
    tail
end

function Base.pushfirst!(list::TaggedIntrusiveList{T, Tag}, node::T) where {T, Tag}
    if isempty(list)
        setnextprevself!(node, Tag)
    else
        circlist_link_before!(list.root::T, node, Tag)
    end
    list.root = node
    list
end

function Base.popfirst!(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    isempty(list) && throw(ArgumentError("list must be non-empty"))
    root = list.root::T
    new_root = circlist_unlink!(root, Tag)
    list.root = root === new_root ? nothing : new_root
    root
end

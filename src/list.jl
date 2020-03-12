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
    head::Union{T, Nothing}

    TaggedIntrusiveList{T, Tag}() where {T, Tag} = new(nothing)
end

const IntrusiveList{T} = TaggedIntrusiveList{T, :default}

@inline function checkbounds(list::IntrusiveList)
    isempty(list) && throw(BoundsError(list))
end

Base.eltype(::Type{TaggedIntrusiveList{T, Tag}}) where {T, Tag} = T

@inline Base.isempty(list::TaggedIntrusiveList) = isnothing(list.head)
@inline Base.empty!(list::TaggedIntrusiveList) = list.head = nothing

function Base.length(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    c = 0
    for n in list
        c += 1
    end
    c
end

@inline function Base.iterate(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    isempty(list) && return nothing
    head = list.head::T
    (head, head)
end

@inline function Base.iterate(list::TaggedIntrusiveList{T, Tag}, state::T) where {T, Tag}
    x = getnext(state, Tag)::T
    x === list.head ? nothing : (x, x)
end

@inline function Base.first(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    @boundscheck checkbounds(list)
    list.head::T
end

@inline function Base.last(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    @boundscheck checkbounds(list)
    getprev(list.head::T, Tag)::T
end


function Base.push!(list::TaggedIntrusiveList{T, Tag}, node::T) where {T, Tag}
    if isempty(list)
        setnextprevself!(node, Tag)
        list.head = node
    else
        circlist_link_before!(list.head::T, node, Tag)
    end
    list
end

function Base.pop!(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    isempty(list) && throw(ArgumentError("list must be non-empty"))
    head = list.head::T
    tail = getprev(head, Tag)::T
    if circlist_unlink!(tail, Tag) === tail
        list.head = nothing
    end
    tail
end

function Base.pushfirst!(list::TaggedIntrusiveList{T, Tag}, node::T) where {T, Tag}
    if isempty(list)
        setnextprevself!(node, Tag)
    else
        circlist_link_before!(list.head::T, node, Tag)
    end
    list.head = node
    list
end

function Base.popfirst!(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    isempty(list) && throw(ArgumentError("list must be non-empty"))
    head = list.head::T
    new_head = circlist_unlink!(head, Tag)
    list.head = head === new_head ? nothing : new_head
    head
end

# TODO: implement deleteafter!
function Base.delete!(list::TaggedIntrusiveList{T, Tag}, node::T) where {T, Tag}
    node_next = circlist_unlink!(node, Tag)
    if node === list.head
        if node_next === node
            list.head = nothing
        else
            list.head = node_next
        end
    end
    list
end

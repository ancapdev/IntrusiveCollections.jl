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

@inline getnext(x::IntrusiveSListNode, tag::Symbol) = x.next
@inline setnext!(x::IntrusiveSListNode{T}, next::IntrusiveSListNode{T}, tag::Symbol) where {T} = x.next = next

@inline function circslist_prev(node::T, start::T, tag::Symbol) where {T}
    prev = start
    x = getnext(start, tag)::T
    while x !== node
        prev = x
        x = getnext(x, tag)::T
    end
    prev
end

mutable struct TaggedIntrusiveSList{T, Tag}
    tail::Union{T, Nothing}

    TaggedIntrusiveSList{T, Tag}() where {T, Tag} = new(nothing)
end

const IntrusiveSList{T} = TaggedIntrusiveSList{T, :default}

@inline function checkbounds(list::IntrusiveSList)
    isempty(list) && throw(BoundsError(list))
end

Base.eltype(::Type{TaggedIntrusiveSList{T, Tag}}) where {T, Tag} = T

@inline Base.isempty(list::TaggedIntrusiveSList) = isnothing(list.tail)
@inline Base.empty!(list::TaggedIntrusiveSList) = list.tail = nothing

# TODO: this is duplicate of list code
function Base.length(list::TaggedIntrusiveSList{T, Tag}) where {T, Tag}
    c = 0
    for n in list
        c += 1
    end
    c
end

@inline function Base.iterate(list::TaggedIntrusiveSList{T, Tag}) where {T, Tag}
    isempty(list) && return nothing
    tail = list.tail::T
    head = getnext(tail, Tag)::T
    (head, head)
end

@inline function Base.iterate(list::TaggedIntrusiveSList{T, Tag}, state::T) where {T, Tag}
    if state === list.tail
        nothing
    else
        x = getnext(state, Tag)::T
        (x, x)
    end
end

@inline function Base.first(list::TaggedIntrusiveSList{T, Tag}) where {T, Tag}
    @boundscheck checkbounds(list)
    getnext(list.tail::T, Tag)::T
end

@inline function Base.last(list::TaggedIntrusiveSList{T, Tag}) where {T, Tag}
    @boundscheck checkbounds(list)
    list.tail::T
end

function Base.push!(list::TaggedIntrusiveSList{T, Tag}, node::T) where {T, Tag}
    if isempty(list)
        setnext!(node, node, Tag)
        list.tail = node
    else
        tail = list.tail::T
        head = getnext(tail, Tag)::T
        setnext!(tail, node, Tag)
        setnext!(node, head, Tag)
        list.tail = node
    end
    list
end

function Base.pop!(list::TaggedIntrusiveSList{T, Tag}) where {T, Tag}
    isempty(list) && throw(ArgumentError("slist must be non-empty"))
    tail = list.tail::T
    head = getnext(tail, Tag)::T
    if head === tail
        list.tail = nothing
    else
        prev = circslist_prev(tail, head, Tag)
        setnext!(prev, head, Tag)
        list.tail = prev
    end
    tail
end

function Base.pushfirst!(list::TaggedIntrusiveSList{T, Tag}, node::T) where {T, Tag}
    if isempty(list)
        setnext!(node, node, Tag)
        list.tail = node
    else
        tail = list.tail::T
        head = getnext(tail, Tag)::T
        setnext!(tail, node, Tag)
        setnext!(node, head, Tag)
    end
    list
end

function Base.popfirst!(list::TaggedIntrusiveSList{T, Tag}) where {T, Tag}
    isempty(list) && throw(ArgumentError("slist must be non-empty"))
    tail = list.tail::T
    head = getnext(tail, Tag)::T
    if head === tail
        list.tail = nothing
    else
        setnext!(tail, getnext(head, Tag)::T, Tag)
    end
    head
end

function deleteafter!(list::TaggedIntrusiveSList{T, Tag}, node::T) where {T, Tag}
    next = getnext(node, Tag)::T
    setnext!(node, getnext(next, Tag)::T, Tag)
    if next === list.tail
        if next === node
            list.tail = nothing
        else
            list.tail = node
        end
    end
    list
end

function Base.delete!(list::TaggedIntrusiveSList{T, Tag}, node::T) where {T, Tag}
    @boundscheck checkbounds(list)
    prev = circslist_prev(node, list.tail::T, Tag)
    deleteafter!(list, prev)
    list
end

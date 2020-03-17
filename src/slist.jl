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
    head = getnext(tail, Val{Tag}())::T
    (head, head)
end

@inline function Base.iterate(list::TaggedIntrusiveSList{T, Tag}, state::T) where {T, Tag}
    if state === list.tail
        nothing
    else
        x = getnext(state, Val{Tag}())::T
        (x, x)
    end
end

@inline function Base.first(list::TaggedIntrusiveSList{T, Tag}) where {T, Tag}
    @boundscheck checkbounds(list)
    getnext(list.tail::T, Val{Tag}())::T
end

@inline function Base.last(list::TaggedIntrusiveSList{T, Tag}) where {T, Tag}
    @boundscheck checkbounds(list)
    list.tail::T
end

function Base.push!(list::TaggedIntrusiveSList{T, Tag}, node::T) where {T, Tag}
    if isempty(list)
        setnext!(node, node, Val{Tag}())
        list.tail = node
    else
        tail = list.tail::T
        head = getnext(tail, Val{Tag}())::T
        setnext!(tail, node, Val{Tag}())
        setnext!(node, head, Val{Tag}())
        list.tail = node
    end
    list
end

function Base.pop!(list::TaggedIntrusiveSList{T, Tag}) where {T, Tag}
    isempty(list) && throw(ArgumentError("slist must be non-empty"))
    tail = list.tail::T
    head = getnext(tail, Val{Tag}())::T
    if head === tail
        list.tail = nothing
    else
        prev = circslist_prev(tail, head, Val{Tag}())
        setnext!(prev, head, Val{Tag}())
        list.tail = prev
    end
    tail
end

function Base.pushfirst!(list::TaggedIntrusiveSList{T, Tag}, node::T) where {T, Tag}
    if isempty(list)
        setnext!(node, node, Val{Tag}())
        list.tail = node
    else
        tail = list.tail::T
        head = getnext(tail, Val{Tag}())::T
        setnext!(tail, node, Val{Tag}())
        setnext!(node, head, Val{Tag}())
    end
    list
end

function Base.popfirst!(list::TaggedIntrusiveSList{T, Tag}) where {T, Tag}
    isempty(list) && throw(ArgumentError("slist must be non-empty"))
    tail = list.tail::T
    head = getnext(tail, Val{Tag}())::T
    if head === tail
        list.tail = nothing
    else
        setnext!(tail, getnext(head, Val{Tag}())::T, Val{Tag}())
    end
    head
end

function deleteafter!(list::TaggedIntrusiveSList{T, Tag}, node::T) where {T, Tag}
    next = getnext(node, Val{Tag}())::T
    setnext!(node, getnext(next, Val{Tag}())::T, Val{Tag}())
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
    prev = circslist_prev(node, list.tail::T, Val{Tag}())
    deleteafter!(list, prev)
    list
end

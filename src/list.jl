mutable struct TaggedIntrusiveList{T, Tag}
    head::Union{T, Nothing}

    TaggedIntrusiveList{T, Tag}() where {T, Tag} = new(nothing)
end

const IntrusiveList{T} = TaggedIntrusiveList{T, :default}

@inline function checkbounds(list::TaggedIntrusiveList)
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

function Base.show(io::IO, list::TaggedIntrusiveList)
    first = true
    print(io, "[")
    for x in list
        !first && print(io, "↔")
        first = false
        print(io, x)
    end
    print(io, "]")
end

@inline function Base.iterate(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    isempty(list) && return nothing
    head = list.head::T
    (head, head)
end

@inline function Base.iterate(list::TaggedIntrusiveList{T, Tag}, state::T) where {T, Tag}
    x = getnext(state, Val{Tag}())::T
    x === list.head ? nothing : (x, x)
end

@inline function Base.first(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    @boundscheck checkbounds(list)
    list.head::T
end

@inline function Base.last(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    @boundscheck checkbounds(list)
    getprev(list.head::T, Val{Tag}())::T
end


function Base.push!(list::TaggedIntrusiveList{T, Tag}, node::T) where {T, Tag}
    if isempty(list)
        setnextprevself!(node, Val{Tag}())
        list.head = node
    else
        circlist_link_before!(list.head::T, node, Val{Tag}())
    end
    list
end

function Base.pop!(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    @boundscheck checkbounds(list)
    head = list.head::T
    tail = getprev(head, Val{Tag}())::T
    if circlist_unlink!(tail, Val{Tag}()) === tail
        list.head = nothing
    end
    tail
end

function Base.pushfirst!(list::TaggedIntrusiveList{T, Tag}, node::T) where {T, Tag}
    if isempty(list)
        setnextprevself!(node, Val{Tag}())
    else
        circlist_link_before!(list.head::T, node, Val{Tag}())
    end
    list.head = node
    list
end

function Base.popfirst!(list::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    @boundscheck checkbounds(list)
    head = list.head::T
    new_head = circlist_unlink!(head, Val{Tag}())
    list.head = head === new_head ? nothing : new_head
    head
end

function Base.delete!(list::TaggedIntrusiveList{T, Tag}, node::T) where {T, Tag}
    node_next = circlist_unlink!(node, Val{Tag}())
    if node === list.head
        if node_next === node
            list.head = nothing
        else
            list.head = node_next
        end
    end
    list
end

function deleteafter!(list::TaggedIntrusiveList{T, Tag}, node::T) where {T, Tag}
    delete!(list, getnext(node, Val{Tag}())::T)
end

function insertafter!(list::TaggedIntrusiveList{T, Tag}, after::T, node::T) where {T, Tag}
    next = getnext(after, Val{Tag}())::T
    circlist_link_before!(next, node, Val{Tag}())
    list
end

function Base.append!(list::TaggedIntrusiveList{T, Tag}, list2::TaggedIntrusiveList{T, Tag}) where {T, Tag}
    isempty(list2) && return list
    if isempty(list)
        list.head = list2.head::T
    else
        head1 = list.head::T
        tail1 = getprev(head1, Val{Tag}())::T
        head2 = list2.head::T
        tail2 = getprev(head2, Val{Tag}())::T
        setnext!(tail1, head2, Val{Tag}())
        setprev!(head2, tail1, Val{Tag}())
        setnext!(tail2, head1, Val{Tag}())
        setprev!(head1, tail2, Val{Tag}())
    end
    list2.head = nothing
    list
end

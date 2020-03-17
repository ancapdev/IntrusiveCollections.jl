@inline function setnextprevself!(x, tag::Val)
    setnext!(x, x, tag)
    setprev!(x, x, tag)
    nothing
end

@inline function circlist_link_before!(x::T, node::T, tag::Val) where {T}
    prev = getprev(x, tag)::T
    setnext!(prev, node, tag)
    setprev!(node, prev, tag)
    setnext!(node, x, tag)
    setprev!(x, node, tag)
    nothing
end

@inline function circlist_unlink!(x::T, tag::Val) where {T}
    prev = getprev(x, tag)::T
    next = getnext(x, tag)::T
    setnext!(prev, next, tag)
    setprev!(next, prev, tag)
    next
end

@inline function circslist_prev(node::T, start::T, tag::Val) where {T}
    prev = start
    x = getnext(start, tag)::T
    while x !== node
        prev = x
        x = getnext(x, tag)::T
    end
    prev
end

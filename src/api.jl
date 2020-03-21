
"""
    getnext(x[, ::Val{Tag}])

Get the next node in a list after `x`. Defaults to `x.next`.
`Tag` identifies the list instance, for nodes that may exist in more than one list.
For implementations of nodes that exist in only a single list at a time,
`getnext` can be implemented without the `Tag` parameter.
"""
@inline getnext(x, ::Val{:default}) = getnext(x)
@inline getnext(x) = x.next

"""
    getprev(x[, ::Val{Tag}])

Get the previous node in a list before `x`. Defaults to `x.prev`.
`Tag` identifies the list instance, for nodes that may exist in more than one list.
For implementations of nodes that exist in only a single list at a time,
`getprev` can be implemented without the `Tag` parameter.
"""
@inline getprev(x, ::Val{:default}) = getprev(x)
@inline getprev(x) = x.prev

"""
    setnext!(x, next, [, ::Val{Tag}])

Link `x` to `next` after `x`. Defaults to `x.next = next`.
`Tag` identifies the list instance, for nodes that may exist in more than one list.
For implementations of nodes that exist in only a single list at a time,
`getnext` can be implemented without the `Tag` parameter.
"""
@inline setnext!(x::T, next::T, ::Val{:default}) where {T} = setnext!(x, next)
@inline setnext!(x::T, next::T) where {T} = x.next = next

"""
    setprev!(x, prev, [, ::Val{Tag}])

Link `x` to `prev` before `x`. Defaults to `x.prev = prev`.
`Tag` identifies the list instance, for nodes that may exist in more than one list.
For implementations of nodes that exist in only a single list at a time,
`getnext` can be implemented without the `Tag` parameter.
"""
@inline setprev!(x::T, prev::T, ::Val{:default}) where {T} = setprev!(x, prev)
@inline setprev!(x::T, prev::T) where {T} = x.prev = prev

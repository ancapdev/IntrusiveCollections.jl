
"""
    getnext(x[, ::Val{Tag}])

Get the next node in a list after `x`.
`Tag` identifies the list instance, for nodes that may exist in more than one list.
For implementations of nodes that exist in only a single list at a time,
`getnext` can be implemented without the `Tag` parameter.
"""
@inline getnext(x, ::Val{:default}) = getnext(x)

"""
    getprev(x[, ::Val{Tag}])

Get the previous node in a list before `x`.
`Tag` identifies the list instance, for nodes that may exist in more than one list.
For implementations of nodes that exist in only a single list at a time,
`getprev` can be implemented without the `Tag` parameter.
"""
@inline getprev(x, ::Val{:default}) = getprev(x)

"""
    setnext!(x, next, [, ::Val{Tag}])

Link `x` to `next` after `x`.
`Tag` identifies the list instance, for nodes that may exist in more than one list.
For implementations of nodes that exist in only a single list at a time,
`getnext` can be implemented without the `Tag` parameter.
"""
@inline setnext!(x::T, next::T, ::Val{:default}) where {T} = setnext!(x, next)

"""
    setprev!(x, prev, [, ::Val{Tag}])

Link `x` to `prev` before `x`.
`Tag` identifies the list instance, for nodes that may exist in more than one list.
For implementations of nodes that exist in only a single list at a time,
`getnext` can be implemented without the `Tag` parameter.
"""
@inline setprev!(x::T, prev::T, ::Val{:default}) where {T} = setprev!(x, prev)

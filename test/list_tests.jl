@testset "IntrusiveList" begin

mutable struct MultiTagListNode
    value::Int64
    next_a::MultiTagListNode
    prev_a::MultiTagListNode
    next_b::MultiTagListNode
    prev_b::MultiTagListNode

    function MultiTagListNode(value)
        x = new(value)
        x.next_a = x
        x.prev_a = x
        x.next_b = x
        x.prev_b = x
        x
    end
end

@inline function IntrusiveCollections.setnext!(x::MultiTagListNode, next::MultiTagListNode, tag::Symbol)
    if tag == :a
        x.next_a = next
    elseif tag == :b
        x.next_b = next
    else
        throw(ArgumentError("Tag must be :a or :b"))
    end
    nothing
end

@inline function IntrusiveCollections.setprev!(x::MultiTagListNode, prev::MultiTagListNode, tag::Symbol)
    if tag == :a
        x.prev_a = prev
    elseif tag == :b
        x.prev_b = prev
    else
        throw(ArgumentError("Tag must be :a or :b"))
    end
    nothing
end

@inline function IntrusiveCollections.getnext(x::MultiTagListNode, tag::Symbol)
    if tag == :a
        return x.next_a
    elseif tag == :b
        return x.next_b
    else
        throw(ArgumentError("Tag must be :a or :b"))
    end
end

@inline function IntrusiveCollections.getprev(x::MultiTagListNode, tag::Symbol)
    if tag == :a
        return x.prev_a
    elseif tag == :b
        return x.prev_b
    else
        throw(ArgumentError("Tag must be :a or :b"))
    end
end

@testset "push and pop" begin
    # TODO: empty!, append!, prepend!
    list = IntrusiveList{IntrusiveListNode{Int}}()
    n1 = IntrusiveListNode(1)
    pushfirst!(list, n1)
    @test !isempty(list)
    @test all([x for x in list] .=== [n1])
    n2 = IntrusiveListNode(2)
    pushfirst!(list, n2)
    @test !isempty(list)
    @test all([x for x in list] .=== [n2, n1])
    @test popfirst!(list) === n2
    @test !isempty(list)
    @test all([x for x in list] .=== [n1])
    @test popfirst!(list) === n1
    @test isempty(list)
    push!(list, n1)
    @test !isempty(list)
    @test all([x for x in list] .=== [n1])
    push!(list, n2)
    @test !isempty(list)
    @test all([x for x in list] .=== [n1, n2])
    @test pop!(list) === n2
    @test !isempty(list)
    @test all([x for x in list] .=== [n1])
    @test pop!(list) === n1
    @test isempty(list)
    @test_throws ArgumentError pop!(list)
end

@testset "empty" begin
    list = IntrusiveList{IntrusiveListNode{Int}}()
    @test isempty(list)
    push!(list, IntrusiveListNode(1))
    @test !isempty(list)
    empty!(list)
    @test isempty(list)
end

@testset "length" begin
    list = IntrusiveList{IntrusiveListNode{Int}}()
    @test length(list) == 0
    push!(list, IntrusiveListNode(1))
    @test length(list) == 1
    push!(list, IntrusiveListNode(2))
    @test length(list) == 2
    pop!(list)
    @test length(list) == 1
end

@testset "splice" begin
    list = IntrusiveList{IntrusiveListNode{Int}}()
    n1 = IntrusiveListNode(1)
    n2 = IntrusiveListNode(2)
    n3 = IntrusiveListNode(3)
    push!(list, n1)
    splice!(list, n1)
    @test isempty(list)
    push!(list, n1, n2)
    splice!(list, n1)
    @test all([x for x in list] .=== [n2])
    pushfirst!(list, n1)
    splice!(list, n2)
    @test all([x for x in list] .=== [n1])
    push!(list, n2, n3)
    splice!(list, n2)
    @test all([x for x in list] .=== [n1, n3])
end

@testset "accessors" begin
    # TODO: isempty, length, in, indexin, first, last
    @test eltype(IntrusiveList{IntrusiveListNode{Int64}}) == IntrusiveListNode{Int64}

    list = IntrusiveList{IntrusiveListNode{Int}}()
    n1 = IntrusiveListNode(1)
    n2 = IntrusiveListNode(2)
    @test_throws BoundsError first(list)
    @test_throws BoundsError last(list)
    push!(list, n1)
    @test first(list) === n1
    @test last(list) === n1
    push!(list, n2)
    @test first(list) === n1
    @test last(list) === n2
end

# getindex, setindex!, lastindex, insert!, deleteat!, splice!
# findfirst, indextoposition, positiontoindex
# keys

# TODO: test empty list
@testset "iteration" begin
    list = IntrusiveList{IntrusiveListNode{Int64}}()
    pushfirst!(list, IntrusiveListNode(1))
    pushfirst!(list, IntrusiveListNode(2))
    pushfirst!(list, IntrusiveListNode(3))
    @test [x.value for x in list] == [3, 2, 1]
end

@testset "tags" begin
    a = TaggedIntrusiveList{MultiTagListNode, :a}()
    b = TaggedIntrusiveList{MultiTagListNode, :b}()
    n1 = MultiTagListNode(1)
    n2 = MultiTagListNode(2)
    n3 = MultiTagListNode(3)
    push!(a, n1)
    @test !isempty(a)
    @test isempty(b)
    @test all([x for x in a] .=== [n1])
    push!(b, n2)
    @test !isempty(a)
    @test !isempty(b)
    @test all([x for x in a] .=== [n1])
    @test all([x for x in b] .=== [n2])
    push!(a, n3)
    @test !isempty(a)
    @test !isempty(b)
    @test all([x for x in a] .=== [n1, n3])
    @test all([x for x in b] .=== [n2])
    @test pop!(b) === n2
    @test !isempty(a)
    @test isempty(b)
    @test all([x for x in a] .=== [n1, n3])
    @test pop!(a) === n3
    @test !isempty(a)
    @test isempty(b)
    @test all([x for x in a] .=== [n1])
    @test pop!(a) === n1
    @test isempty(a)
    @test isempty(b)
end

@testset "output" begin
end

end

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

IntrusiveCollections.setnext!(x::MultiTagListNode, next::MultiTagListNode, ::Val{:a}) = x.next_a = next
IntrusiveCollections.setnext!(x::MultiTagListNode, next::MultiTagListNode, ::Val{:b}) = x.next_b = next
IntrusiveCollections.setprev!(x::MultiTagListNode, prev::MultiTagListNode, ::Val{:a}) = x.prev_a = prev
IntrusiveCollections.setprev!(x::MultiTagListNode, prev::MultiTagListNode, ::Val{:b}) = x.prev_b = prev
IntrusiveCollections.getnext(x::MultiTagListNode, ::Val{:a}) = x.next_a
IntrusiveCollections.getnext(x::MultiTagListNode, ::Val{:b}) = x.next_b
IntrusiveCollections.getprev(x::MultiTagListNode, ::Val{:a}) = x.prev_a
IntrusiveCollections.getprev(x::MultiTagListNode, ::Val{:b}) = x.prev_b

list_types = [
    IntrusiveList{IntrusiveListNode{Int}},
    IntrusiveSList{IntrusiveSListNode{Int}}
]

@testset "push and pop $ListType" for ListType in list_types
    # TODO: empty!, append!, prepend!
    NodeType = eltype(ListType)
    list = ListType()
    n1 = NodeType(1)
    pushfirst!(list, n1)
    @test !isempty(list)
    @test all([x for x in list] .=== [n1])
    n2 = NodeType(2)
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

@testset "empty $ListType" for ListType in list_types
    list = ListType()
    @test isempty(list)
    push!(list, eltype(ListType)(1))
    @test !isempty(list)
    empty!(list)
    @test isempty(list)
end

@testset "length $ListType" for ListType in list_types
    NodeType = eltype(ListType)
    list = ListType()
    @test length(list) == 0
    push!(list, NodeType(1))
    @test length(list) == 1
    push!(list, NodeType(2))
    @test length(list) == 2
    pop!(list)
    @test length(list) == 1
end

@testset "delete $ListType" for ListType in list_types
    NodeType = eltype(ListType)
    list = ListType()
    n1 = NodeType(1)
    n2 = NodeType(2)
    n3 = NodeType(3)
    push!(list, n1)
    delete!(list, n1)
    @test isempty(list)
    push!(list, n1, n2)
    delete!(list, n1)
    @test all([x for x in list] .=== [n2])
    pushfirst!(list, n1)
    delete!(list, n2)
    @test all([x for x in list] .=== [n1])
    push!(list, n2, n3)
    delete!(list, n2)
    @test all([x for x in list] .=== [n1, n3])
end

@testset "deleteafter $ListType" for ListType in list_types
    NodeType = eltype(ListType)
    list = ListType()
    n1 = NodeType(1)
    n2 = NodeType(2)
    n3 = NodeType(3)
    push!(list, n1)
    deleteafter!(list, n1)
    @test isempty(list)
    push!(list, n1, n2)
    deleteafter!(list, n2)
    @test all([x for x in list] .=== [n2])
    pushfirst!(list, n1)
    deleteafter!(list, n1)
    @test all([x for x in list] .=== [n1])
    push!(list, n2, n3)
    deleteafter!(list, n1)
    @test all([x for x in list] .=== [n1, n3])
end

@testset "append $ListType" for ListType in list_types
    NodeType = eltype(ListType)
    list1 = ListType()
    list2 = ListType()
    n1 = NodeType(1)
    n2 = NodeType(2)
    n3 = NodeType(3)
    n4 = NodeType(4)
    # empty -> empty
    append!(list1, list2)
    @test isempty(list1)
    @test isempty(list2)
    # empty -> [1]
    push!(list2, n1)
    append!(list1, list2)
    @test isempty(list2)
    @test all([x for x in list1] .=== [n1])
    # empty -> [1, 2]
    list1 = ListType()
    list2 = ListType()
    push!(list2, n1, n2)
    append!(list1, list2)
    @test isempty(list2)
    @test all([x for x in list1] .=== [n1, n2])
    # [1] -> empty
    list1 = ListType()
    list2 = ListType()
    push!(list1, n1)
    append!(list1, list2)
    @test isempty(list2)
    @test all([x for x in list1] .=== [n1])
    # [1] -> [2]
    list1 = ListType()
    list2 = ListType()
    push!(list1, n1)
    push!(list2, n2)
    append!(list1, list2)
    @test isempty(list2)
    @test all([x for x in list1] .=== [n1, n2])
    # [1, 2] -> [3]
    list1 = ListType()
    list2 = ListType()
    push!(list1, n1, n2)
    push!(list2, n3)
    append!(list1, list2)
    @test isempty(list2)
    @test all([x for x in list1] .=== [n1, n2, n3])
    # [1, 2] -> [3, 4]
    list1 = ListType()
    list2 = ListType()
    push!(list1, n1, n2)
    push!(list2, n3, n4)
    append!(list1, list2)
    @test isempty(list2)
    @test all([x for x in list1] .=== [n1, n2, n3, n4])
end

@testset "accessors $ListType" for ListType in list_types
    # TODO: isempty, length, in, indexin, first, last
    NodeType = eltype(ListType)
    list = ListType()
    n1 = NodeType(1)
    n2 = NodeType(2)
    @test_throws BoundsError first(list)
    @test_throws BoundsError last(list)
    push!(list, n1)
    @test first(list) === n1
    @test last(list) === n1
    push!(list, n2)
    @test first(list) === n1
    @test last(list) === n2
end

@testset "iteration $ListType" for ListType in list_types
    NodeType = eltype(ListType)
    list = ListType()
    @test isempty(collect(list))
    @test typeof(collect(list)) == Vector{NodeType}
    pushfirst!(list, NodeType(1))
    pushfirst!(list, NodeType(2))
    pushfirst!(list, NodeType(3))
    @test [x.value for x in list] == [3, 2, 1]
end

@testset "tags $ListType" for ListType in (TaggedIntrusiveList, TaggedIntrusiveSList)
    a = ListType{MultiTagListNode, :a}()
    b = ListType{MultiTagListNode, :b}()
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
    list = IntrusiveList{IntrusiveListNode{Int}}()
    @test "$list" == "[]"
    push!(list, IntrusiveListNode(1))
    @test "$list" == "[1]"
    push!(list, IntrusiveListNode(2))
    @test "$list" == "[1↔2]"
    push!(list, IntrusiveListNode(3))
    @test "$list" == "[1↔2↔3]"
    list = IntrusiveSList{IntrusiveSListNode{Int}}()
    @test "$list" == "[]"
    push!(list, IntrusiveSListNode(1))
    @test "$list" == "[1]"
    push!(list, IntrusiveSListNode(2))
    @test "$list" == "[1→2]"
    push!(list, IntrusiveSListNode(3))
    @test "$list" == "[1→2→3]"
end

end

@testset "IntrusiveList" begin

@testset "initial state" begin
    list = IntrusiveList{IntrusiveListNode{Int64}}()
    @test isempty(list)
end

@testset "modifiers" begin
    # push!, pop!, pushfirst!, popfirst!, empty!
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
    
end

@testset "accessors" begin
    # eltype, isempty, length, in, indexin, first, last, append, prepend
    @test eltype(IntrusiveList{IntrusiveListNode{Int64}}) == IntrusiveListNode{Int64}

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
end

@testset "output" begin
end

end

module IntrusiveCollections

export TaggedIntrusiveList, IntrusiveList, IntrusiveListNode
export TaggedIntrusiveSList, IntrusiveSList, IntrusiveSListNode
export deleteafter!, insertafter!

include("api.jl")
include("utility.jl")
include("list_node.jl")
include("list.jl")
include("slist_node.jl")
include("slist.jl")

end

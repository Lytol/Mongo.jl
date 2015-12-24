module Mongo

include("../deps/deps.jl")

using LibBSON

import Base.show,
    Base.convert,
    Base.start,
    Base.next,
    Base.count,
    Base.find,
    Base.done

ccall(
    (:mongoc_init, libmongoc),
    Void, ()
    )
atexit() do
    ccall((:mongoc_cleanup, libmongoc), Void, ())
end

typealias NakedDict Union{Pair,Tuple}

include("MongoClient.jl")
include("MongoCollection.jl")
include("MongoCursor.jl")
include("query.jl")

end

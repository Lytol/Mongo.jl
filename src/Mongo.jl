module Mongo

include("../deps/deps.jl")

using LibBSON

import Base.show,
    Base.convert,
    Base.insert,
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

include("MongoClient.jl")
include("MongoCollection.jl")
include("MongoCursor.jl")

end

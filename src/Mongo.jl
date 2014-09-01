module Mongo

const MONGO_LIB = "libmongoc-1.0"

using LibBSON

import Base.show,
    Base.convert,
    Base.insert

ccall(
    (:mongoc_init, MONGO_LIB),
    Void, ()
    )
atexit() do
    ccall((:mongoc_cleanup, MONGO_LIB), Void, ())
end

include("MongoClient.jl")
include("MongoCollection.jl")

end

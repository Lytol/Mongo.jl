module Mongo

const MONGO_LIB = "libmongoc-1.0"

using LibBSON

import Base.show,
    Base.convert,
    Base.insert

include("MongoClient.jl")
include("MongoCollection.jl")

end

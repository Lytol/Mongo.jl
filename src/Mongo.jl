module Mongo

const MONGO_LIB = "libmongoc-1.0"

using LibBSON

import Base.show

include("MongoClient.jl")

end

module Mongo

export MONGO_ERROR, MONGO_OK

const MONGO_SHARED_LIBRARY = "/usr/local/lib/libmongoc"
const MONGO_OK = 0
const MONGO_ERROR = -1

include("mongo_client.jl")
include("mongo_cursor.jl")

end

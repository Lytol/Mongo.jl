module Mongo

const MONGO_SHARED_LIBRARY = "/usr/local/lib/libmongoc"

include("client.jl")
include("cursor.jl")

end

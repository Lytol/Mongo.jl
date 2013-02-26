require("src/BSON")

module Mongo

using BSON

export MONGO_ERROR, MONGO_OK,
       find

const MONGO_SHARED_LIBRARY = "/usr/local/lib/libmongoc"
const MONGO_OK = 0
const MONGO_ERROR = -1

include("mongo_client.jl")
include("mongo_cursor.jl")

function find(client::MongoClient, namespace::String, query::BSONObject, fields::BSONObject, limit::Int, skip::Int)
  MongoCursor(client, namespace, query, fields, limit, skip)
end

find(client::MongoClient, namespace::String, query::BSONObject, fields::BSONObject) = find(client, namespace, query, fields, 0, 0)
find(client::MongoClient, namespace::String, query::BSONObject) = find(client, namespace, query, BSONObject(), 0, 0)
find(client::MongoClient, namespace::String) = find(client, namespace, BSONObject(), BSONObject(), 0, 0)

end

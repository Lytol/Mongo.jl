require("src/BSON")

module Mongo

using BSON

export MONGO_ERROR, MONGO_OK,
       find, find_one

const MONGO_LIB = "libmongoc"
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


function find_one(client::MongoClient, namespace::String, query::BSONObject, fields::BSONObject)
    bson = BSONObject()
    errno = ccall((:mongo_find_one, MONGO_LIB), Int32, (Ptr{Void},Ptr{Uint8},Ptr{Void},Ptr{Void},Ptr{Void}),
                client._mongo, bytestring(namespace), query._bson, fields._bson, bson._bson)
    errno == MONGO_ERROR ? nothing : bson
end
find_one(client::MongoClient, namespace::String, query::BSONObject) = find_one(client, namespace, query, BSONObject())
find_one(client::MongoClient, namespace::String) = find_one(client, namespace, BSONObject(), BSONObject())

end

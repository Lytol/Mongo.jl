module Mongo

include("BSON.jl")
using Mongo.BSON

export UPSERT, MULTI,
       find, find_one, count, update, insert, remove, dropdb!, run_command

const MONGO_LIB = "libmongoc"
const MONGO_OK = 0
const MONGO_ERROR = -1

# Update flags
const UPSERT = 1
const MULTI  = 2

include("mongo_client.jl")
include("mongo_cursor.jl")

function run_command(client::MongoClient, dbname::String, command::BSONObject)
    bson = BSONObject()
    errno = ccall((:mongo_run_command, MONGO_LIB), Int32,
                  (Ptr{Void}, Ptr{Uint8}, Ptr{Void}, Ptr{Void}),
                  client._mongo, bytestring(dbname), command._bson, bson._bson)
    errno == MONGO_ERROR ? nothing : bson
end

function find(client::MongoClient, namespace::String, query, fields, limit::Int, skip::Int)
    MongoCursor(client, namespace, BSONObject(query), BSONObject(fields), limit, skip)
end
find(client::MongoClient, namespace::String, query, fields) = find(client, namespace, query, fields, 0, 0)
find(client::MongoClient, namespace::String, query) = find(client, namespace, query, BSONObject(), 0, 0)
find(client::MongoClient, namespace::String) = find(client, namespace, BSONObject(), BSONObject(), 0, 0)

function find_one(client::MongoClient, namespace::String, query, fields)
    bson = BSONObject()
    errno = ccall((:mongo_find_one, MONGO_LIB), Int32, (Ptr{Void},Ptr{Uint8},Ptr{Void},Ptr{Void},Ptr{Void}),
                client._mongo, bytestring(namespace), BSONObject(query)._bson, BSONObject(fields)._bson, bson._bson)
    errno == MONGO_ERROR ? nothing : dict(bson)
end
find_one(client::MongoClient, namespace::String, query) = find_one(client, namespace, query, BSONObject())
find_one(client::MongoClient, namespace::String) = find_one(client, namespace, BSONObject(), BSONObject())

function count(client::MongoClient, namespace::String, query)
    db, collection = split(namespace, '.')
    c = ccall((:mongo_count, MONGO_LIB), Float64, (Ptr{Void}, Ptr{Uint8}, Ptr{Uint8}, Ptr{Void}),
                client._mongo, bytestring(db), bytestring(collection), BSONObject(query)._bson)
    if c == MONGO_ERROR
        error("Unable to perform Mongo count – mongo_count()")
    end
    convert(Int, c)
end
count(client::MongoClient, namespace::String) = count(client, namespace, BSONObject())

function update(client::MongoClient, namespace::String, query, op, flags::Int)
    errno = ccall((:mongo_update, MONGO_LIB), Int32, (Ptr{Void}, Ptr{Uint8}, Ptr{Void}, Ptr{Void}, Int32, Ptr{Void}),
                client._mongo, bytestring(namespace), BSONObject(query)._bson, BSONObject(op)._bson, convert(Int32, flags), C_NULL)
    if errno == MONGO_ERROR
        error("Unable to update document(s) – mongo_update()")
    end
end
update(client::MongoClient, namespace::String, query, op) = update(client, namespace, query, op, 0)

function insert(client::MongoClient, namespace::String, bson)
    errno = ccall((:mongo_insert, MONGO_LIB), Int32, (Ptr{Void}, Ptr{Uint8}, Ptr{Void}, Ptr{Void}),
                client._mongo, bytestring(namespace), BSONObject(bson)._bson, C_NULL)
    if errno == MONGO_ERROR
        error("Unable to insert document(s) – mongo_insert()")
    end
end

function remove(client::MongoClient, namespace::String, query)
    errno = ccall((:mongo_remove, MONGO_LIB), Int32, (Ptr{Void}, Ptr{Uint8}, Ptr{Void}, Ptr{Void}),
        client._mongo, bytestring(namespace), BSONObject(query)._bson, C_NULL)
    if errno == MONGO_ERROR
        error("Unable to remove document(s) – mongo_remove()")
    end
end

function dropdb!(client::MongoClient, dbname::String)
    errno = ccall((:mongo_cmd_drop_db, MONGO_LIB), Int32, (Ptr{Void}, Ptr{Uint8}),
                  client._mongo, bytestring(dbname))
    if errno == MONGO_ERROR
        error("Unable to drop database $(repr(dbname))")
    end
end

end # module Mongo

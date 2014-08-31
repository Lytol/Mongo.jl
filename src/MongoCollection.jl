type MongoCollection
    _wrap_::Ptr{Void}

    MongoCollection(client::MongoClient, db::String, name::String) = begin
        dbCStr = bytestring(db)
        nameCStr = bytestring(name)
        collection = new(
            ccall(
                (:mongoc_client_get_collection, MONGO_LIB),
                Ptr{Void}, (Ptr{Void}, Ptr{Uint8}, Ptr{Uint8}),
                client._wrap_, dbCStr, nameCStr
                )
            )
        finalizer(collection, destroy)
        return collection
    end
end
export MongoCollection

show(io::IO, collection::MongoCollection) = begin
    nameCStr = ccall(
        (:mongoc_collection_get_name, MONGO_LIB),
        Ptr{Uint8}, (Ptr{Void},),
        collection._wrap_
        )
    name = bytestring(nameCStr)
    print(io, "MongoCollection($name)")
end
export show

const MONGO_INSERT_NONE = 0
const MONGO_INSERT_CONTINUE_ON_ERROR = 1

insert(
    collection::MongoCollection,
    document::BSON,
    flags::Int = MONGO_INSERT_NONE
    ) = begin
    bsonError = BSONError()
    ccall(
        (:mongoc_collection_insert, MONGO_LIB),
        Bool, (Ptr{Void}, Cint, Ptr{Void}, Ptr{Void}, Ptr{Uint8}),
        collection._wrap_,
        flags,
        document._wrap_,
        C_NULL,
        bsonError._wrap_
        ) || error("insert: $(string(bsonError))")
end
export insert

# Private

destroy(collection::MongoCollection) =
    ccall(
        (:mongoc_collection_destroy, MONGO_LIB),
        Void, (Ptr{Void},),
        collection._wrap_
        )

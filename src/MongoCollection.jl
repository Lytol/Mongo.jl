type MongoCollection
    _wrap_::Ptr{Void}

    MongoCollection(client::MongoClient, db::String, name::String) = begin
        dbCStr = bytestring(db)
        nameCStr = bytestring(name)
        collection = new(
            ccall(
                (:mongoc_client_get_collection, libmongoc),
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
        (:mongoc_collection_get_name, libmongoc),
        Ptr{Uint8}, (Ptr{Void},),
        collection._wrap_
        )
    name = bytestring(nameCStr)
    print(io, "MongoCollection($name)")
end
export show

baremodule MongoInsertFlags
    const None = 0
    const ContinueOnError = 1
end
export MongoInsertFlags

insert(
    collection::MongoCollection,
    document::BSONObject;
    flags::Int = MongoInsertFlags.None
    ) = begin
    bsonError = BSONError()
    ccall(
        (:mongoc_collection_insert, libmongoc),
        Bool, (Ptr{Void}, Cint, Ptr{Void}, Ptr{Void}, Ptr{Uint8}),
        collection._wrap_,
        flags,
        document._wrap_,
        C_NULL,
        bsonError._wrap_
        ) || error("insert: $(string(bsonError))")
end
insert(
    collection::MongoCollection,
    dict::Associative;
    flags::Int = MongoInsertFlags.None
    ) = insert(collection, BSONObject(dict), flags=flags)
export insert

baremodule MongoUpdateFlags
    const None = 0
    const Upsert = 1
    const MultiUpdate = 2
end
export MongoUpdateFlags

update(
    collection::MongoCollection,
    queryBSON::BSONObject,
    updateBSON::BSONObject;
    flags::Int = MongoUpdateFlags.None
    ) = begin
    bsonError = BSONError()
    ccall(
        (:mongoc_collection_update, libmongoc),
        Bool, (Ptr{Void}, Cint, Ptr{Void}, Ptr{Void}, Ptr{Void}, Ptr{Uint8}),
        collection._wrap_,
        flags,
        queryBSON._wrap_,
        updateBSON._wrap_,
        C_NULL,
        bsonError._wrap_
        ) || error("update: $(string(bsonError))")
end
export update

baremodule MongoQueryFlags
    const None              = 0
    const TailableCursor    = 2
    const SlaveIO           = 4
    const OplogReplay       = 8
    const NoCursorTimeout   = 16
    const AwaitData         = 32
    const Exhaust           = 64
    const Partial           = 128
end
export MongoQueryFlags

count(
    collection::MongoCollection,
    queryBSON::BSONObject;
    skip::Int64 = 0,
    limit::Int64 = -1,
    flags::Int = MongoQueryFlags.None
    ) = begin
    bsonError = BSONError()
    result = ccall(
        (:mongoc_collection_count, libmongoc),
        Bool, (Ptr{Void}, Cint, Ptr{Void}, Int64, Int64, Ptr{Void}, Ptr{Uint8}),
        collection._wrap_,
        flags,
        queryBSON._wrap_,
        skip,
        limit,
        C_NULL,
        bsonError._wrap_
        )
    result < 0 && error("count: $(string(bsonError))")
    return result
end
count(
    collection::MongoCollection,
    query::Associative;
    skip::Int64 = 0,
    limit::Int64 = -1,
    flags::Int = MongoQueryFlags.None
    ) = count(
        collection,
        BSONObject(query),
        skip = skip,
        limit = limit,
        flags = flags
        )
export count

destroy(collection::MongoCollection) =
    ccall(
        (:mongoc_collection_destroy, libmongoc),
        Void, (Ptr{Void},),
        collection._wrap_
        )

type MongoCollection
    _wrap_::Ptr{Void}

    MongoCollection(client::MongoClient, db::AbstractString, name::AbstractString) = begin
        dbCStr = bytestring(db)
        nameCStr = bytestring(name)
        collection = new(
            ccall(
                (:mongoc_client_get_collection, libmongoc),
                Ptr{Void}, (Ptr{Void}, Ptr{UInt8}, Ptr{UInt8}),
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
        Ptr{UInt8}, (Ptr{Void},),
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
    oid = get!(document, "_id", BSONOID())

    bsonError = BSONError()
    ccall(
        (:mongoc_collection_insert, libmongoc),
        Bool, (Ptr{Void}, Cint, Ptr{Void}, Ptr{Void}, Ptr{UInt8}),
        collection._wrap_,
        flags,
        document._wrap_,
        C_NULL,
        bsonError._wrap_
        ) || error("insert: $(string(bsonError))")

    return oid
end
insert(
    collection::MongoCollection,
    dict::Associative;
    flags::Int = MongoInsertFlags.None
    ) = insert(collection, BSONObject(dict), flags=flags)
insert(
    collection::MongoCollection,
    dict::NakedDict;
    flags::Int = MongoInsertFlags.None
    ) = insert(collection, BSONObject(Dict(dict)), flags=flags)
export insert

baremodule MongoUpdateFlags
    const None = 0
    const Upsert = 1
    const MultiUpdate = 2
end
export MongoUpdateFlags

update(
    collection::MongoCollection,
    selector::BSONObject,
    change::BSONObject;
    flags::Int = MongoUpdateFlags.None
    ) = begin
    bsonError = BSONError()
    ccall(
        (:mongoc_collection_update, libmongoc),
        Bool, (Ptr{Void}, Cint, Ptr{Void}, Ptr{Void}, Ptr{Void}, Ptr{UInt8}),
        collection._wrap_,
        flags,
        selector._wrap_,
        change._wrap_,
        C_NULL,
        bsonError._wrap_
        ) || error("update: $(string(bsonError))")
end
update(
    collection::MongoCollection,
    selector::Associative,
    change::Associative;
    flags::Int = MongoUpdateFlags.None
    ) = update(
        collection,
        BSONObject(selector),
        BSONObject(change),
        flags = flags
        )
update(c::MongoCollection, s::NakedDict, chg::NakedDict; kwargs...) =
    update(c, BSONObject(Dict(s)), BSONObject(Dict(chg)); kwargs...)
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

Base.find(
    collection::MongoCollection,
    selector::BSONObject,
    fields::BSONObject;
    flags::Int = MongoQueryFlags.None,
    skip::Int = 0,
    limit::Int = 0,
    batch_size::Int = 0
    ) = begin
    result = ccall(
        (:mongoc_collection_find, libmongoc),
        Ptr{Void}, (Ptr{Void}, Cint, UInt32, UInt32, UInt32, Ptr{Void}, Ptr{Void}, Ptr{Void}),
        collection._wrap_,
        flags,
        skip,
        limit,
        batch_size,
        selector._wrap_,
        fields._wrap_,
        C_NULL
        )
    result == C_NULL && error("mongoc_collection_find: failure")
    return MongoCursor( result )
end
Base.find(
    collection::MongoCollection,
    selector::Associative,
    fields::Associative;
    skip::Int = 0,
    limit::Int = 0,
    batch_size::Int = 0,
    flags::Int = MongoQueryFlags.None
    ) = find(
        collection,
        BSONObject(selector),
        BSONObject(fields),
        skip = skip,
        limit = limit,
        batch_size = batch_size,
        flags = flags
        )
Base.find(
    collection::MongoCollection,
    selector::BSONObject;
    flags::Int = MongoQueryFlags.None,
    skip::Int = 0,
    limit::Int = 0,
    batch_size::Int = 0
    ) = begin
    result = ccall(
        (:mongoc_collection_find, libmongoc),
        Ptr{Void}, (Ptr{Void}, Cint, UInt32, UInt32, UInt32, Ptr{Void}, Ptr{Void}, Ptr{Void}),
        collection._wrap_,
        flags,
        skip,
        limit,
        batch_size,
        selector._wrap_,
        C_NULL,
        C_NULL
        )
    result == C_NULL && error("mongoc_collection_find: failure")
    return MongoCursor( result )
end
Base.find(
    collection::MongoCollection,
    selector::Associative;
    skip::Int = 0,
    limit::Int = 0,
    batch_size::Int = 0,
    flags::Int = MongoQueryFlags.None
    ) = find(
        collection,
        BSONObject(selector),
        skip = skip,
        limit = limit,
        batch_size = batch_size,
        flags = flags
        )
Base.find(c::MongoCollection, s::NakedDict; kwargs...) =
    find(c, BSONObject(Dict(s)); kwargs...)
Base.find(c::MongoCollection, s::NakedDict, f::NakedDict; kwargs...) =
    find(c, BSONObject(Dict(s)), BSONObject(Dict(f)); kwargs...)
export find

Base.count(
    collection::MongoCollection,
    queryBSON::BSONObject;
    skip::Int64 = 0,
    limit::Int64 = 0,
    flags::Int = MongoQueryFlags.None
    ) = begin
    bsonError = BSONError()
    result = ccall(
        (:mongoc_collection_count, libmongoc),
        Int64, (Ptr{Void}, Cint, Ptr{Void}, Int64, Int64, Ptr{Void}, Ptr{UInt8}),
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
Base.count(
    collection::MongoCollection,
    query::Associative;
    skip::Int64 = 0,
    limit::Int64 = 0,
    flags::Int = MongoQueryFlags.None
    ) = count(
        collection,
        BSONObject(query),
        skip = skip,
        limit = limit,
        flags = flags
        )
Base.count(c::MongoCollection, s::NakedDict; kwargs...) =
    count(c, BSONObject(Dict(s)); kwargs...)
Base.count(c::MongoCollection) = count(c, BSONObject())
export count

baremodule MongoDeleteFlags
    const None              = 0
    const SingleRemove      = 1
end
export MongoDeleteFlags

delete(
    collection::MongoCollection,
    selector::BSONObject;
    flags::Int = MongoDeleteFlags.None
    ) = begin
    bsonError = BSONError()
    result = ccall(
        (:mongoc_collection_delete, libmongoc),
        Bool, (Ptr{Void}, Cint, Ptr{Void}, Ptr{Void}, Ptr{UInt8}),
        collection._wrap_,
        flags,
        selector._wrap_,
        C_NULL,
        bsonError._wrap_
        )
    result < 0 && error("delete: $(string(bsonError))")
    return result
end
delete(
    collection::MongoCollection,
    selector::Associative;
    flags::Int = MongoDeleteFlags.None
    ) = delete(
        collection,
        BSONObject(selector),
        flags = flags
        )
delete(c::MongoCollection, s::NakedDict; kwargs...) =
    delete(c, BSONObject(Dict(s)); kwargs...)
export delete

destroy(collection::MongoCollection) =
    ccall(
        (:mongoc_collection_destroy, libmongoc),
        Void, (Ptr{Void},),
        collection._wrap_
        )

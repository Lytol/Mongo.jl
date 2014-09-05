type MongoCursor
    _wrap_::Ptr{Void}

    MongoCursor(_wrap_::Ptr{Void}) = begin
        cursor = new(_wrap_)
        finalizer(cursor, destroy)
        return cursor
    end
end
export MongoCursor

next(cursor::MongoCursor) = begin
    bsonObjectPtr = Array(Ptr{Void}, 1)
    ccall(
        (:mongoc_cursor_next, libmongoc),
        Bool, (Ptr{Void}, Ptr{Ptr{Void}}),
        cursor._wrap_,
        bsonObjectPtr
        ) || error("mongoc_cursor_next: failure")
    return BSONObject(bsonObjectPtr[1])
end
export next

destroy(collection::MongoCursor) =
    ccall(
        (:mongoc_cursor_destroy, libmongoc),
        Void, (Ptr{Void},),
        collection._wrap_
        )

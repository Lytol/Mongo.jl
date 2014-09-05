type MongoCursor
    _wrap_::Ptr{Void}

    MongoCursor(_wrap_::Ptr{Void}) = begin
        cursor = new(_wrap_)
        finalizer(cursor, destroy)
        return cursor
    end
end
export MongoCursor

current(cursor::MongoCursor) = begin
    return BSONObject(
        ccall(
            (:mongoc_cursor_current, libmongoc),
            Ptr{Void}, (Ptr{Void},),
            cursor._wrap_
            )
        )
end

destroy(collection::MongoCursor) =
    ccall(
        (:mongoc_cursor_destroy, libmongoc),
        Void, (Ptr{Void},),
        collection._wrap_
        )

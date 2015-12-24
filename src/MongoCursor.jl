type MongoCursor
    _wrap_::Ptr{Void}

    MongoCursor(_wrap_::Ptr{Void}) = begin
        cursor = new(_wrap_)
        finalizer(cursor, destroy)
        return cursor
    end
end
export MongoCursor

# Iterator

start(cursor::MongoCursor) = nothing
export start

next(cursor::MongoCursor, _::Void) =
    (BSONObject(ccall(
        (:mongoc_cursor_current, libmongoc),
        Ptr{Void}, (Ptr{Void},),
        cursor._wrap_
        ), Union{}), _)
export next

done(cursor::MongoCursor, _::Void) = begin
    return !ccall(
        (:mongoc_cursor_next, libmongoc),
        Bool, (Ptr{Void}, Ptr{Ptr{Void}}),
        cursor._wrap_,
        Array(Ptr{Void}, 1)
        )
end
export done

destroy(collection::MongoCursor) =
    ccall(
        (:mongoc_cursor_destroy, libmongoc),
        Void, (Ptr{Void},),
        collection._wrap_
        )

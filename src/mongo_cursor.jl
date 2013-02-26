export MongoCursor,
       query, fields

using BSON

type MongoCursor
    client::MongoClient
    namespace::String
    query::BSONObject
    fields::BSONObject
    _cursor::Ptr{Void}

    function MongoCursor(client::MongoClient, namespace::String, q, f)
        p = ccall((:mongo_cursor_create, MONGO_SHARED_LIBRARY), Ptr{Void}, ())
        if p == C_NULL
            error("Unable to create mongo cursor – mongo_cursor_create() failed")
        end

        ccall((:mongo_cursor_init, MONGO_SHARED_LIBRARY),
            Void,
            (Ptr{Void}, Ptr{Void}, Ptr{Uint8}),
            p, client._mongo, bytestring(namespace))

        cursor = new(client, namespace, q, f, p)
        finalizer(cursor, destroy)

        query(cursor, q)
        fields(cursor, f)

        return cursor
    end
end

MongoCursor(client::MongoClient, namespace::String) = MongoCursor(client, namespace, BSONObject(), BSONObject())
MongoCursor(client::MongoClient, namespace::String, query::BSONObject) = MongoCursor(client, namespace, query, BSONObject())

function query(cursor::MongoCursor, query::BSONObject)
    cursor.query = query
    ccall((:mongo_cursor_set_query, MONGO_SHARED_LIBRARY), Void, (Ptr{Void}, Ptr{Void}), cursor._cursor, query._bson)
end

function fields(cursor::MongoCursor, fields::BSONObject)
    cursor.fields = fields
    ccall((:mongo_cursor_set_fields, MONGO_SHARED_LIBRARY), Void, (Ptr{Void}, Ptr{Void}), cursor._cursor, fields._bson)
end


## Iterator ##
import Base.start, Base.next, Base.done

start(c::MongoCursor) = ccall((:mongo_cursor_next, MONGO_SHARED_LIBRARY), Int32, (Ptr{Void},), c._cursor)
done(c::MongoCursor, errno::Int32) = (errno != MONGO_OK)
next(c::MongoCursor, errno::Int32) = begin
    _current_bson = ccall((:mongo_cursor_bson, MONGO_SHARED_LIBRARY), Ptr{Void}, (Ptr{Void},), c._cursor)

    # Create a copy of the bson
    _bson = ccall((:bson_create, MONGO_SHARED_LIBRARY), Ptr{Void}, ())
    errno = ccall((:bson_copy, MONGO_SHARED_LIBRARY), Int32, (Ptr{Void}, Ptr{Void}), _bson, _current_bson)
    if errno == BSON_ERROR
      error("Could not copy BSON object")
    end

    errno = ccall((:mongo_cursor_next, MONGO_SHARED_LIBRARY), Int32, (Ptr{Void},), c._cursor)

    (BSONObject(_bson), errno)
end


## Private Methods ##

function destroy(cursor::MongoCursor)
    errno = ccall((:mongo_cursor_destroy, MONGO_SHARED_LIBRARY), Int32, (Ptr{Void},), cursor._cursor)
    if errno == MONGO_ERROR
        error("Unable to destroy mongo cursor – mongo_cursor_destroy() failed")
    end
end

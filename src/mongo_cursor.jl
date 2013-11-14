export MongoCursor,
       query, fields, limit, skip

type MongoCursor
    client::MongoClient
    namespace::String
    query::BSONObject
    fields::BSONObject
    limit::Int
    skip::Int
    _cursor::Ptr{Void}

    function MongoCursor(client::MongoClient, namespace::String, q, f, l, s)
        p = ccall((:mongo_cursor_alloc, MONGO_LIB), Ptr{Void}, ())
        if p == C_NULL
            error("Unable to create mongo cursor – mongo_cursor_alloc() failed")
        end

        ccall((:mongo_cursor_init, MONGO_LIB),
            Void,
            (Ptr{Void}, Ptr{Void}, Ptr{Uint8}),
            p, client._mongo, bytestring(namespace))

        cursor = new(client, namespace, q, f, l, s, p)
        finalizer(cursor, destroy)

        query(cursor, q)
        fields(cursor, f)
        limit(cursor, l)
        skip(cursor, s)

        return cursor
    end
end

MongoCursor(client::MongoClient, namespace::String) = MongoCursor(client, namespace, BSONObject(), BSONObject(), 0, 0)


query(cursor::MongoCursor, query::Dict) = query(cursor, BSONObject(query))
function query(cursor::MongoCursor, query::BSONObject)
    cursor.query = query
    ccall((:mongo_cursor_set_query, MONGO_LIB), Void, (Ptr{Void}, Ptr{Void}), cursor._cursor, query._bson)
end

fields(cursor::MongoCursor, fields::Dict) = query(cursor, BSONObject(fields))
function fields(cursor::MongoCursor, fields::BSONObject)
    cursor.fields = fields
    ccall((:mongo_cursor_set_fields, MONGO_LIB), Void, (Ptr{Void}, Ptr{Void}), cursor._cursor, fields._bson)
end

function limit(cursor::MongoCursor, limit::Int)
    cursor.limit = limit
    ccall((:mongo_cursor_set_limit, MONGO_LIB), Void, (Ptr{Void}, Int32), cursor._cursor, limit)
end

function skip(cursor::MongoCursor, skip::Int)
    cursor.skip = skip
    ccall((:mongo_cursor_set_skip, MONGO_LIB), Void, (Ptr{Void}, Int32), cursor._cursor, skip)
end


## Iterator ##
import Base.start, Base.next, Base.done

start(c::MongoCursor) = ccall((:mongo_cursor_next, MONGO_LIB), Int32, (Ptr{Void},), c._cursor)
done(c::MongoCursor, errno::Int32) = begin
    if errno != MONGO_OK
        reset(c)
        return true
    end
    return false
end

next(c::MongoCursor, errno::Int32) = begin
    _current_bson = ccall((:mongo_cursor_bson, MONGO_LIB), Ptr{Void}, (Ptr{Void},), c._cursor)

    # Create a copy of the bson
    _bson = ccall((:bson_alloc, MONGO_LIB), Ptr{Void}, ())
    errno = ccall((:bson_copy, MONGO_LIB), Int32, (Ptr{Void}, Ptr{Void}), _bson, _current_bson)
    if errno == BSON_ERROR
      error("Could not copy BSON object")
    end

    errno = ccall((:mongo_cursor_next, MONGO_LIB), Int32, (Ptr{Void},), c._cursor)

    (dict(BSONObject(_bson)), errno)
end


## Private Methods ##

function destroy(cursor::MongoCursor)
    errno = ccall((:mongo_cursor_destroy, MONGO_LIB), Int32, (Ptr{Void},), cursor._cursor)
    if errno == MONGO_ERROR
        error("Unable to destroy mongo cursor – mongo_cursor_destroy() failed")
    end
end

function reset(cursor::MongoCursor)
    ccall((:mongo_cursor_init, MONGO_LIB), Void,
      (Ptr{Void}, Ptr{Void}, Ptr{Uint8}),
      cursor._cursor, cursor.client._mongo, bytestring(cursor.namespace))
end

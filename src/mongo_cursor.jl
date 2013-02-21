export MongoCursor,
       find

using BSON

type MongoCursor
    client::MongoClient
    namespace::String
    _cursor::Ptr{Void}

    function MongoCursor(client::MongoClient, namespace::String)
      p = ccall((:mongo_find, MONGO_SHARED_LIBRARY),
            Ptr{Void},
            (Ptr{Void}, Ptr{Uint8}, Ptr{Void}, Ptr{Void}, Int32, Int32, Int32), 
            client._mongo, bytestring(namespace), C_NULL, C_NULL, 0, 0, 0)
      if p == C_NULL
        error("Error while creating cursor")
      end

      cursor = new(client, namespace, p)

      return cursor
    end
end

find(client::MongoClient, namespace::String) = MongoCursor(client, namespace)

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


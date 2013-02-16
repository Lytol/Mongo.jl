export Cursor,
       find

type Cursor
    client::Client
    namespace::String
    _cursor::Ptr{Void}

    function Cursor(client::Client, namespace::String)
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

function find(client::Client, namespace::String)
    return Cursor(client, namespace)
end

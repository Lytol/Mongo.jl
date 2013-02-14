export MongoClient, close

const mongo_error = -1

type MongoClient
    host::String
    port::Integer
    mongo::Ptr{Void}

    function MongoClient(host::String, port::Integer)
        p = ccall((:mongo_create, "/usr/local/lib/libmongoc.dylib"), Ptr{Void},  ())
        if p == C_NULL
            # Throw exception
        end

        errno = ccall((:mongo_client, "/usr/local/lib/libmongoc.dylib"), Int32, (Ptr{Void},Ptr{Uint8},Int32), p, bytestring(host), port)
        if errno == mongo_error
            # Throw exception
        end

        mclt = new(host, port, p)

        finalizer(mclt, close)

        return mclt
    end
end

function close(client::MongoClient)
    ccall((:mongo_destroy, "/usr/local/lib/libmongoc.dylib"), Void, (Ptr{Void},), client.mongo)
end

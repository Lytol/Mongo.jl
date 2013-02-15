export Client, close

const MONGO_ERROR = -1
const MONGO_SHARED_LIBRARY = "/usr/local/lib/libmongoc"

type Client
    host::String
    port::Integer
    mongo::Ptr{Void}

    function Client(host::String, port::Integer)
        p = ccall((:mongo_create, MONGO_SHARED_LIBRARY), Ptr{Void},  ())
        if p == C_NULL
            error("Could not create a mongo object")
        end

        client = new(host, port, p)
        finalizer(client, close)

        errno = ccall((:mongo_client, MONGO_SHARED_LIBRARY), Int32, (Ptr{Void},Ptr{Uint8},Int32), client.mongo, bytestring(host), port)
        if errno == MONGO_ERROR
            error("mongo_client error: $(last_error(client))")
        end

        return client
    end
end

function close(client::Client)
    ccall((:mongo_destroy, MONGO_SHARED_LIBRARY), Void, (Ptr{Void},), client.mongo)
end

function last_error(client::Client)
    ccall((:mongo_get_err, MONGO_SHARED_LIBRARY), Int32, (Ptr{Void},), client.mongo)
end

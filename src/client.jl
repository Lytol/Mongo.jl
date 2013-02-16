export Client

const MONGO_ERROR = -1

type Client
    host::String
    port::Integer
    _mongo::Ptr{Void}

    function Client(host::String, port::Integer)
        p = ccall((:mongo_create, MONGO_SHARED_LIBRARY), Ptr{Void},  ())
        if p == C_NULL
            error("Could not create a mongo object")
        end

        client = new(host, port, p)
        finalizer(client, destroy)

        errno = ccall((:mongo_client, MONGO_SHARED_LIBRARY), Int32, (Ptr{Void},Ptr{Uint8},Int32), client._mongo, bytestring(host), port)
        if errno == MONGO_ERROR
            error("mongo_client error: $(last_error(client))")
        end

        return client
    end
end

Client() = Client("localhost", 27017)


### Private methods ###

function destroy(client::Client)
    ccall((:mongo_destroy, MONGO_SHARED_LIBRARY), Void, (Ptr{Void},), client._mongo)
end

function last_error(client::Client)
    ccall((:mongo_get_err, MONGO_SHARED_LIBRARY), Int32, (Ptr{Void},), client._mongo)
end

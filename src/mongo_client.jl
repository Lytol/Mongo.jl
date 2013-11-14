export MongoClient

type MongoClient
    host::String
    port::Integer
    _mongo::Ptr{Void}

    function MongoClient(host::String, port::Integer)
        p = ccall((:mongo_alloc, MONGO_LIB), Ptr{Void},  ())
        if p == C_NULL
            error("Could not create a mongo object")
        end

        client = new(host, port, p)
        finalizer(client, destroy)

        connect(client)

        return client
    end
end

MongoClient() = MongoClient("localhost", 27017)


### Private methods ###

function connect(client::MongoClient)
    errno = ccall((:mongo_client, MONGO_LIB), Int32, (Ptr{Void},Ptr{Uint8},Int32), client._mongo, bytestring(client.host), client.port)
    if errno == MONGO_ERROR
        error("mongo_client error: $(last_error(client))")
    end
end

function destroy(client::MongoClient)
    ccall((:mongo_destroy, MONGO_LIB), Void, (Ptr{Void},), client._mongo)
end

function last_error(client::MongoClient)
    ccall((:mongo_get_err, MONGO_LIB), Int32, (Ptr{Void},), client._mongo)
end

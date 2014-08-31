type MongoClient
    uri::String
    _wrap_::Ptr{Void}

    MongoClient(host::String = "localhost", port::Int = 27017) = begin
        uri = "mongodb://$host:$port/"
        uriCStr = bytestring(uri)
        client = new(
            uri,
            ccall(
                (:mongoc_client_new, MONGO_LIB),
                Ptr{Void}, (Ptr{Uint8}, ),
                uriCStr
                )
            )
        finalizer(client, destroy)
        return client
    end
end
export MongoClient

show(io::IO, client::MongoClient) = print(io, "MongoClient($(client.uri))")
export show

# Private

destroy(client::MongoClient) =
    ccall(
        (:mongoc_client_destroy, BSON_LIB),
        Void, (Ptr{Void},),
        client._wrap_
        )

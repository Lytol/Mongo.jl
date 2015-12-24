type MongoClient
    uri::AbstractString
    _wrap_::Ptr{Void}
    _closed::Bool

    MongoClient(uri::AbstractString) = begin
        uriCStr = bytestring(uri)
        client = new(
            uri,
            ccall(
                (:mongoc_client_new, libmongoc),
                Ptr{Void}, (Ptr{UInt8}, ),
                uriCStr
                ),
            false
            )
        finalizer(client, destroy)
        return client
    end

MongoClient(host::AbstractString, port::Int) = MongoClient("mongodb://$host:$port/")
MongoClient(host::AbstractString, port::Int, user::AbstractString, password::AbstractString) = MongoClient("mongodb://$user:$password@$host:$port/")
MongoClient(host::AbstractString, user::AbstractString, password::AbstractString) = MongoClient("mongodb://$user:$password@$host/")
MongoClient(host::AbstractString, user::AbstractString, password::AbstractString, db::AbstractString) = MongoClient("mongodb://$user:$password@$host/$db")
    MongoClient() = MongoClient("localhost", 27017)
end
export MongoClient

show(io::IO, client::MongoClient) = print(io, "MongoClient($(client.uri))")
export show

# Private

destroy(client::MongoClient) =
    if !client._closed
        ccall(
            (:mongoc_client_destroy, libmongoc),
            Void, (Ptr{Void},),
            client._wrap_
            )
        client._closed = true
    end

using FactCheck, LibBSON, Mongo

mongoDBDir = "/tmp/Mongo.jl-test.db"
mkpath(mongoDBDir)
mongod = spawn(`mongod --dbpath $mongoDBDir`)
sleep(1) # wait for listen on port

facts("Mongo") do
    client = MongoClient()
    collection = MongoCollection(client, "foo", "bar")
    oid = BSONOID()

    context("insert") do
        insert(collection, Dict("_id" => oid, "hello" => "before"))
        @fact count(collection, Dict("_id" => oid)) --> 1
        for item in find(collection, Dict("_id" => oid), Dict("_id" => false, "hello" => true))
            @fact dict(item) --> Dict("hello" => "before")
        end
    end

    context("update") do
        update(
            collection,
            Dict("_id" => oid),
            Dict("\$set" => Dict("hello" => "after"))
            )
        @fact count(collection, Dict("_id" => oid)) --> 1
        for item in find(collection, Dict("_id" => oid), Dict("_id" => false, "hello" => true))
            @fact dict(item) --> Dict("hello" => "after")
        end
    end

    context("delete") do
        delete(
            collection,
            Dict("_id" => oid)
            )
        @fact count(collection, Dict("_id" => oid)) --> 0
    end
end

facts("Mongo: bad host/port") do
    client = MongoClient("bad-host-name", 9999)
    collection = MongoCollection(client, "foo", "bar")
    @fact_throws insert(collection, Dict("foo" => "bar"))
end

kill(mongod)
rm(mongoDBDir, recursive=true)

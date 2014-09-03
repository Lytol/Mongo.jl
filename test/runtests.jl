using FactCheck, LibBSON, Mongo

include("deps/deps.jl")

facts("Mongo") do
    client = MongoClient()
    collection = MongoCollection(client, "foo", "bar")
    oid = BSONOID()

    context("insert") do
        insert(collection, {"_id"=>oid, "hello"=>"before"})
        @fact count(collection, {"_id"=>oid}) => 1
    end

    context("update") do
        update(
            collection,
            BSONObject({"_id"=>oid}),
            BSONObject({"\$set"=>{"hello"=>"after"}})
            )
    end
end

facts("Mongo: bad host/port") do
    client = MongoClient("bad-host-name", 9999)
    collection = MongoCollection(client, "foo", "bar")
    @fact_throws insert(collection, {"foo"=>"bar"})
end

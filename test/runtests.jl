using FactCheck, LibBSON, Mongo

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
            {"_id"=>oid},
            {"\$set"=>{"hello"=>"after"}}
            )
        @fact count(collection, {"_id"=>oid}) => 1
    end

    context("delete") do
        delete(
            collection,
            {"_id"=>oid}
            )
        @fact count(collection, {"_id"=>oid}) => 0
    end
end

facts("Mongo: bad host/port") do
    client = MongoClient("bad-host-name", 9999)
    collection = MongoCollection(client, "foo", "bar")
    @fact_throws insert(collection, {"foo"=>"bar"})
end

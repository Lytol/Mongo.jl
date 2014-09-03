using FactCheck, LibBSON, Mongo

facts("Mongo: insert") do
    client = MongoClient()
    collection = MongoCollection(client, "foo", "bar")
    oid = BSONOID()
    insert(collection, BSONObject({"_id"=>oid, "hello"=>"before"}))
    update(collection, BSONObject({"_id"=>oid}), BSONObject({"\$set"=>{"hello"=>"after"}}), MongoUpdateFlags.MultiUpdate)
end

facts("Mongo: bad host/port") do
    client = MongoClient("bad-host-name", 9999)
    collection = MongoCollection(client, "foo", "bar")
    @fact_throws insert(collection, {"foo"=>"bar"})
end

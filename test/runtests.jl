using FactCheck, LibBSON, Mongo

facts("Mongo: insert") do
    client = MongoClient()
    collection = MongoCollection(client, "foo", "bar")
    oid = BSONOID()
    append(document, )
    insert(collection, BSONObject({"_id"=>oid, "hello"=>"before"}))
    update(collection, BSONObject({"_id"=>oid}), BSONObject({"\$set"=>{"hello"=>"after"}}), MongoUpdateFlags.MultiUpdate)
end

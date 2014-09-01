using FactCheck, LibBSON, Mongo

facts("Mongo: insert") do
    client = MongoClient()
    collection = MongoCollection(client, "foo", "bar")
    document = BSON()
    oid = BSONOID()
    append(document, "_id", oid)
    append(document, "hello", "before")
    insert(collection, document)
    q = BSON()
    u = BSON("{\"\$set\": {\"hello\": \"after\"}}")
    update(collection, q, u, MongoUpdateFlags.MultiUpdate)
end

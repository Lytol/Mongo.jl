using FactCheck, LibBSON, Mongo

facts("insert") do
    client = MongoClient()
    collection = MongoCollection(client, "foo", "bar")
    document = BSON()
    append(document, "foo", 43)
    insert(collection, document)
end

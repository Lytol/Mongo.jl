require("src/BSON.jl")
require("src/Mongo.jl")

using Mongo

client = MongoClient()

for bson in find(client, "test.mongojl")
    for obj in bson
        println(obj)
    end
    println("--------------------------------------")
end

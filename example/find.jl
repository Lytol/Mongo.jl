require("src/BSON.jl")
require("src/Mongo.jl")

using Mongo

client = MongoClient()

for o in find(client, "test.names")
  print(o)
end


Mongo.jl
========

MongoDB bindings for Julia


Installing
----------

You must have the Mongo C drivers installed, see <https://github.com/mongodb/mongo-c-driver>.



Getting Started
---------------

    require("Mongo.jl")

    using Mongo
    using BSON

    client = MongoClient()

    query = BSONObject({ "name" => "Brian" })
    fields = BSONObject({ "name" => 1, "age" => 1 })

    cursor = MongoCursor(client, "test.people", query, fields)

    for o in cursor
        println("Name: $(get(o, "name")) / Age: $(get(o, "age"))")
    end


Mongo.jl
========

MongoDB bindings for [The Julia Language](http://julialang.org/)


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

    cursor = find(client, "test.people", query, fields)

    for o in cursor
        println("Name: " * get(o, "name"))
        println(dict(o))
    end


Contributing
------------

**Fork and send a pull request or create a [GitHub issue](https://github.com/Lytol/Mongo.jl/issues) and I'll try and respond quickly**

### Running the Test Suite

Make sure to `cd` to the project root and run the following:

    julia test/run.jl


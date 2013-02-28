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

    client = MongoClient()   # Defaults to MongoClient("localhost", 27017)

    # Insert a few documents
    insert(client, "test.people", BSONObject({ "name" => "Brian", "age" => 30, "hobbies" => {"surfing", "coding", "video games"}}))
    insert(client, "test.people", BSONObject({ "name" => "Lizzie", "age" => 30, "hobbies" => {"traveling", "crafts", "movies"}}))
    insert(client, "test.people", BSONObject({ "name" => "Adam", "age" => 31, "hobbies" => {"climbing", "cycling"}}))

    # Find Brian
    bson = find_one(client, "test.people", BSONObject({ "name" => "Brian" }))

    # Change his age to 31
    update(client, "test.people", BSONObject({ "_id" => get(bson, "_id") }), BSONObject({ "\$set" => { "age" => 31 }}))

    # Change everyone's age to 30
    update(client, "test.people", BSONObject(), BSONObject({ "\$set" => { "age" => 30 }}), MULTI)

    # Change Adam back to 31
    update(client, "test.people", BSONObject({ "name" => "Adam" }), BSONObject({ "\$set" => { "age" => 31 }}))

    # Find everyone's name and age and display
    query = BSONObject()
    fields = BSONObject({ "name" => 1, "age" => 1 })

    cursor = find(client, "test.people", query, fields)

    for o in cursor
        println("Name: " * get(o, "name") * " / Age: " * string(get(o, "age")))     # Or simply, println(o)
    end

    # Remove Lizze
    remove(client, "test.people", BSONObject({ "name" => "Lizzie" }))

    # Actually, let's just remove everyone
    remove(client, "test.people", BSONObject())


Contributing
------------

**Fork and send a pull request or create a [GitHub issue](https://github.com/Lytol/Mongo.jl/issues) and I'll try and respond quickly**

### Running the Test Suite

Make sure to `cd` to the project root and run the following:

    julia test/run.jl


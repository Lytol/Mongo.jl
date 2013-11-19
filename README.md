Mongo.jl
========

MongoDB bindings for [The Julia Language](http://julialang.org/)


Installing
----------

You must have the Mongo C drivers installed, see <https://github.com/mongodb/mongo-c-driver>.


Getting Started
---------------

    using Mongo

    client = MongoClient()   # Defaults to MongoClient("localhost", 27017)

    # Insert a few documents
    insert(client, "test.people", { "name" => "Brian", "age" => 30, "hobbies" => {"surfing", "coding", "video games"}})
    insert(client, "test.people", { "name" => "Lizzie", "age" => 30, "hobbies" => {"traveling", "crafts", "movies"}})
    insert(client, "test.people", { "name" => "Adam", "age" => 31, "hobbies" => {"climbing", "cycling"}})

    # Find Brian
    obj = find_one(client, "test.people", { "name" => "Brian" })

    # Change his age to 31
    update(client, "test.people", { "_id" => obj["_id"] }, { "\$set" => { "age" => 31 }})

    # Change everyone's age to 30
    update(client, "test.people", Dict(), { "\$set" => { "age" => 30 }}, MULTI)

    # Change Adam back to 31
    update(client, "test.people", { "name" => "Adam" }, { "\$set" => { "age" => 31 }})

    # Find everyone's name and age and display
    fields = { "name" => 1, "age" => 1 }

    cursor = find(client, "test.people", Dict(), fields)

    for o in cursor
        println("Name: " * o["name"] * " / Age: " * string(o["age"]))  # Or simply, println(o)
    end

    # Remove Lizze
    remove(client, "test.people", { "name" => "Lizzie" })

    # Actually, let's just remove everyone
    remove(client, "test.people", Dict())


Development
-----------

### Running the Test Suite

NOTE: _MongoDB server must be running on localhost_

* `cd` to the project root and run the following: `julia test/run.jl`


Contributing
------------

**Fork and send a pull request or create a [GitHub issue](https://github.com/Lytol/Mongo.jl/issues) and I'll try and respond quickly**

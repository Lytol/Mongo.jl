[![Build Status](https://travis-ci.org/pzion/Mongo.jl.svg?branch=master)](https://travis-ci.org/pzion/Mongo.jl)

Mongo.jl
===========

[MongoDB](http://www.mongodb.org) bindings for [The Julia Language](http://julialang.org/)


License
-------

This software is licensed under the simplified BSD license; see the file LICENSE for details.


Installing
----------

Building the driver should build and/or install the MongoDB C driver for you.


Setup
-----

You must have a MongoDB server running somewhere.  You can specify the host and port in the MongoClient constructor, otherwise it uses the Mongo defaults.


Getting Started
---------------

    using Mongo, LibBSON

    # Create a client connection
    client = MongoClient() # default locahost:27017

    # Get a hangle to collection named "cats" in database "db"
    collection = MongoCollection(client, "db", "cats")

    # Insert a document
    # Mokie is a pretty old cat
    oid = insert(collection, {"name"=>"Mokie", "age"=>17})

    # Ensure it was inserted by counting
    println(count(collection, {"name"=>"Mokie"}))
    println(count(collection, {"_id"=>oid}))

    # Print all the documents
    for doc in find(collection, {"name"=>"Mokie"})
        println(doc)
    end

    # It's Mokie's birthday!
    # Update the document and print the new docs
    update(collection, {"_id"=>oid}, {"age"=>18})
    for doc in find(collection, {"name"=>"Mokie"})
        println(doc)
    end

    # Delete the document and ensure it is no more by counting
    delete(collection, {"_id"=>oid})
    println(count(collection, {"name"=>"Mokie"}))

Contributing
------------

Contributions are welcome!  Please fork on github.com and submit a pull request if you have a contribution you think is worthwhile!

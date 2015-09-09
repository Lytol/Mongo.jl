Mongo.jl
===========

[![Build Status](https://api.travis-ci.org/pzion/Mongo.jl.svg?branch=master)](https://travis-ci.org/pzion/Mongo.jl)
[![Pkgs Status](http://pkg.julialang.org/badges/Mongo_release.svg)](http://pkg.julialang.org/?pkg=Mongo&ver=release)
[![Coverage Status](https://img.shields.io/coveralls/pzion/Mongo.jl.svg)](https://coveralls.io/r/pzion/Mongo.jl?branch=master)

[MongoDB](http://www.mongodb.org) bindings for [The Julia Language](http://julialang.org/)


License
-------

This software is licensed under the simplified BSD license; see the file LICENSE for details.


Installing
----------

Building this package should build and/or install the MongoDB C driver for you.


Setup
-----

You must have a MongoDB server running somewhere.  You can specify the host and port in the MongoClient constructor, otherwise it uses the Mongo default locahost:27017.


Getting Started
---------------

    using Mongo, LibBSON

    # Create a client connection
    client = MongoClient() # default locahost:27017

    # Get a handle to collection named "cats" in database "db"
    collection = MongoCollection(client, "db", "cats")

    # Insert a document
    # Mokie is a pretty old cat
    oid = insert(collection, Dict("name"=>"Mokie", "age"=>17))

    # Ensure it was inserted by counting
    println(count(collection, Dict("name"=>"Mokie")))
    println(count(collection, Dict("_id"=>oid)))

    # Print all the documents with a name of Mokie
    for doc in find(collection, Dict("name"=>"Mokie"))
        println(doc)
    end

    # It's Mokie's birthday!
    # Update the document and print the new docs
    update(collection, Dict("_id"=>oid), Dict("age"=>18))
    for doc in find(collection, Dict("name"=>"Mokie"))
        println(doc)
    end

    # Delete the document and ensure it is no more by counting
    delete(collection, Dict("_id"=>oid))
    println(count(collection, Dict("name"=>"Mokie")))

Contributing
------------

Contributions are welcome!  Please fork on github.com and submit a pull request if you have a contribution you think is worthwhile!

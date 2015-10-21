Mongo.jl
===========

[![Build Status](https://api.travis-ci.org/pzion/Mongo.jl.svg?branch=master)](https://travis-ci.org/pzion/Mongo.jl)
[![0.4 Status](http://pkg.julialang.org/badges/Mongo_0.4.svg)](http://pkg.julialang.org/?pkg=Mongo)
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

````julia
using Mongo, LibBSON

# Create a client connection
client = MongoClient() # default locahost:27017

# Get a handle to collection named "cats" in database "db"
collection = MongoCollection(client, "db", "cats")

# Insert a document
# Mokie is a pretty old cat
m_oid = insert(collection, Dict("name"=>"Mokie", "age"=>17))
# Pebbles is an even older cat
p_oid = insert(collection, Dict("name"=>"Pebbles", "age"=>19))

# Ensure they were inserted by counting
println(count(collection, Dict("name"=>"Mokie")))
println(count(collection))

# Print all cats under age 19
# The query function returns a pair with the key "$query"
# There are functional shortcuts for many MongoDB modifiers and operators, here
# we use $lt
for doc in find(collection, query("age" => lt(19)))
    println("$(doc["name"]) is younger than 19")
end

# It's Mokie's birthday!
# We can use the shortcut for the "$inc" operator to increase Mokie's age by 1
# Notice how we can use a Tuple as our query instead of typing "Dict" over and over
update(collection, ("_id"=>m_oid), inc("age"=>1))
for doc in find(collection, Dict("name"=>"Mokie"))
    println(doc)
end

# Delete the document and ensure it is no more by counting
delete(collection, Dict("_id"=>m_oid))
println(count(collection, Dict("name"=>"Mokie")))
````

Contributing
------------

Contributions are welcome!  Please fork on github.com and submit a pull request if you have a contribution you think is worthwhile!

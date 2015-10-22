using FactCheck, LibBSON, Mongo

facts("Mongo") do
    client = MongoClient()
    collection = MongoCollection(client, "foo", "bar")
    oid = BSONOID()

    context("insert") do
        insert(collection, ("_id" => oid, "hello" => "before"))
        @fact count(collection, ("_id" => oid)) --> 1
        @fact count(collection) --> 1
        for item in find(collection, ("_id" => oid), ("_id" => false, "hello" => true))
            @fact dict(item) --> Dict("hello" => "before")
        end
    end

    context("update") do
        update(
            collection,
            ("_id" => oid),
            set("hello" => "after")
            )
        @fact count(collection, ("_id" => oid)) --> 1
        for item in find(collection, ("_id" => oid), ("_id" => false, "hello" => true))
            @fact dict(item) --> Dict("hello" => "after")
        end
    end

    context("delete") do
        delete(
            collection,
            ("_id" => oid)
            )
        @fact count(collection, ("_id" => oid)) --> 0
        @fact count(collection) --> 0
    end
end

facts("Mongo: bad host/port") do
    client = MongoClient("bad-host-name", 9999)
    collection = MongoCollection(client, "foo", "bar")
    @fact_throws insert(collection, ("foo" => "bar"))
end

facts("Query building helpers") do
    client = MongoClient()
    ppl = MongoCollection(client, "foo", "ppl")
    person(name, age) = insert(ppl, ("name" => name, "age" => age))
    person("Tim", 25)
    person("Jason", 21)
    person("Jim", 87)
    context("orderby") do
        @fact first(find(ppl, (query(), orderby("age" => -1))))["name"] --> "Jim"
        @fact first(find(ppl, (query(), orderby("age" => 1))))["name"] --> "Jason"
    end
    context("gt and lt") do
        @fact first(find(ppl, query("age" => lt(25))))["name"] --> "Jason"
        @fact first(find(ppl, query("age" => gt(50))))["name"] --> "Jim"
    end
    context("in and nin") do
        @fact first(find(ppl, query("age" => in([21]))))["name"] --> "Jason"
        @fact first(find(ppl, query("age" => nin([21,25]))))["name"] --> "Jim"
    end
    context("eq and ne") do
        @fact first(find(ppl, query("age" => eq(21))))["name"] --> "Jason"
        @fact first(find(ppl, query("age" => ne(87))))["name"] == "Jim" --> false
    end
    context("update with operator") do
        update(ppl, ("age" => 87), set("age" => 88))
        @fact first(find(ppl, query("name" => "Jim")))["age"] --> 88
    end
    delete(ppl, ())
end

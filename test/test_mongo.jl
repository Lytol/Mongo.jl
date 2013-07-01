require("src/Mongo")
require("src/BSON")
using FactCheck, Mongo, BSON

function with_test_db(f)
    client = MongoClient()
    dbname = randstring(15)

    try
        f(client, dbname)
    finally
        dropdb!(client, dbname)
    end
end

function itr_to_arr(itr)
    arr = {}
    for el in itr push!(arr, el) end
    arr
end

@facts "Mongo" begin

    with_test_db() do client, dbname

        @fact "Can insert and count documents" begin
            insert(client, "$dbname.people", BSONObject({"name" => "Brian",
                                                         "age" => 30}))
            insert(client, "$dbname.people", BSONObject({"name" => "Lizzie",
                                                         "age" => 30}))
            count(client, "$dbname.people") => 2
        end

        @fact "Can find_one document, delete it, then find nothing" begin
            insert(client, "$dbname.animals", BSONObject({"type" => "dog",
                                                          "name" => "Spot"}))

            query = BSONObject({"type" => "dog"})

            dict(find_one(client, "$dbname.animals", query)) => (d) -> begin
                d["type"] == "dog" && d["name"] == "Spot" && haskey(d, "_id")
            end

            remove(client, "$dbname.animals", query)

            find_one(client, "$dbname.animals", query) => nothing
        end

        @fact "Can find many documents" begin
            insert(client, "$dbname.foobar", BSONObject({"type" => "foo"}))
            insert(client, "$dbname.foobar", BSONObject({"type" => "bar"}))
            length(itr_to_arr(find(client, "$dbname.foobar"))) => 2
        end

        @fact "Can update documents" begin
            insert(client, "$dbname.plants", BSONObject({"type" => "rose",
                                                         "color" => "red"}))

            query = BSONObject({"type" => "rose"})

            dict(find_one(client, "$dbname.plants", query)) => (d) -> begin
                d["color"] == "red"
            end

            update(client, "$dbname.plants", query, BSONObject({"\$set" =>
                                                                {"color" => "blue"}}))

            dict(find_one(client, "$dbname.plants", query)) => (d) -> begin
                d["color"] == "blue"
            end
        end

    end

end
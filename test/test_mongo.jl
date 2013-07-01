require("src/Mongo")
using FactCheck, Mongo

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
            insert(client, "$dbname.people", {"name" => "Brian", "age" => 30})
            insert(client, "$dbname.people", {"name" => "Lizzie", "age" => 30})
            count(client, "$dbname.people") => 2
        end

        @fact "Can find_one document, delete it, then find nothing" begin
            insert(client, "$dbname.animals", {"type" => "dog", "name" => "Spot"})

            query = {"type" => "dog"}

            find_one(client, "$dbname.animals", query) => (d) -> begin
                typeof(d) <: Dict &&
                d["type"] == "dog" &&
                d["name"] == "Spot" &&
                haskey(d, "_id")
            end

            remove(client, "$dbname.animals", query)

            find_one(client, "$dbname.animals", query) => nothing
        end

        @fact "Can find many documents" begin
            insert(client, "$dbname.foobar", {"type" => "foo"})
            insert(client, "$dbname.foobar", {"type" => "bar"})

            docs = itr_to_arr(find(client, "$dbname.foobar"))

            length(docs) => 2
            typeof(docs[1]) => t -> t <: Dict
        end

        @fact "Can update documents" begin
            insert(client, "$dbname.plants", {"type" => "rose", "color" => "red"})

            query = {"type" => "rose"}

            find_one(client, "$dbname.plants", query) => (d) -> begin
                d["color"] == "red"
            end

            update(client, "$dbname.plants", query, {"\$set" => {"color" => "blue"}})

            find_one(client, "$dbname.plants", query) => (d) -> begin
                d["color"] == "blue"
            end
        end

    end

end
using FactCheck, Mongo.BSON

facts("BSON") do

    context("BSON objects are not null") do
        bson = BSONObject()
        @fact bson._bson => not(C_NULL)
        @fact dict(bson) => Dict{Any,Any}()
    end

    context("BSON objects can be created from Dicts") do
        bson = BSONObject({"name" => "Brian"})
        @fact dict(bson) => {"name" => "Brian"}
    end

    context("Values can be retrieved from BSON objects") do
        bson = BSONObject({"name" => "Brian"})
        @fact get(bson, "name") => "Brian"
        @fact bson["name"] => "Brian"
        @fact get(bson, "age")  => :throws
        @fact get(bson, "age", 123) => 123
    end

    context("BSON objects are iterable") do
        bson = BSONObject({"name" => "Brian", "age" => 30})
        d = Dict{Any,Any}()
        for (k,v) in bson
            d[k] = v
        end
        @fact d => {"name" => "Brian", "age" => 30}
    end

end

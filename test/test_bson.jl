require("src/BSON")
using FactCheck, BSON

@facts "BSON" begin

    @fact "BSON objects are not null" begin
        bson = BSONObject()
        bson._bson => not(C_NULL)
        dict(bson) => Dict{Any,Any}()
    end

    @fact "BSON objects can be created from Dicts" begin
        bson = BSONObject({"name" => "Brian"})
        dict(bson) => {"name" => "Brian"}
    end

    @fact "Values can be retrieved from BSON objects" begin
        bson = BSONObject({"name" => "Brian"})
        get(bson, "name") => "Brian"
        get(bson, "age")  => :throws
        get(bson, "age", 123) => 123
    end

    @fact "BSON objects are iterable" begin
        bson = BSONObject({"name" => "Brian", "age" => 30})
        d = Dict{Any,Any}()
        for (k,v) in bson
            d[k] = v
        end
        d => {"name" => "Brian", "age" => 30}
    end

end
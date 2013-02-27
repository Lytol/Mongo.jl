require("src/BSON")
using BSON

test_context("BSON")

test_group("BSONObject()")
bson = BSONObject()
@test bson._bson != C_NULL
@test dict(bson) == Dict{Any,Any}()

test_group("BSONObject(Dict)")
bson = BSONObject({ "name" => "Brian" })
@test dict(bson) == { "name" => "Brian" }

test_group("dict(bson)")
bson = BSONObject({ "name" => "Brian" })
@test dict(bson) == { "name" => "Brian" }

test_group("get(bson, key)")
bson = BSONObject({ "name" => "Brian" })
@test get(bson, "name") == "Brian"
@test get(bson, "age") == nothing

test_group("Iterator")
bson = BSONObject({ "name" => "Brian", "age" => 30 })
d = Dict{Any,Any}()
for (k,v) in bson
  d[k] = v
end
@test d == { "name" => "Brian", "age" => 30 }

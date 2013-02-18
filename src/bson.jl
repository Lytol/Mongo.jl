module BSON

export BSONObject,
       BSON_OK, BSON_ERROR

const BSON_LIBRARY_PATH = "/usr/local/lib/libbson"
const BSON_OK = 0
const BSON_ERROR = -1

type BSONObject
    _bson::Ptr{Void}

    function BSONObject(_bson::Ptr{Void})
        bson = new(_bson)
        finalizer(bson, destroy)
        return bson
    end
end

BSONObject() = begin
  _bson = ccall((:bson_create, BSON_LIBRARY_PATH), Ptr{Void}, ())
  BSONObject(_bson)
end


### Private methods ###

function destroy(bson::BSONObject)
    ccall((:bson_destroy, BSON_LIBRARY_PATH), Void, (Ptr{Void},), bson_object._bson)
end

end

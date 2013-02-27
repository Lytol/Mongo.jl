module BSON

export BSONObject, ObjectID, 
       BSON_OK, BSON_ERROR,
       dict, get

import Base.show,
       Base.start,
       Base.next,
       Base.done

const BSON_LIB = "libmongoc"
const BSON_OK = 0
const BSON_ERROR = -1

## BSON types ##
const BSON_EOO = 0
const BSON_DOUBLE = 1
const BSON_STRING = 2
const BSON_OBJECT = 3
const BSON_ARRAY = 4
const BSON_BINDATA = 5
const BSON_UNDEFINED = 6
const BSON_OID = 7
const BSON_BOOL = 8
const BSON_DATE = 9
const BSON_NULL = 10
const BSON_REGEX = 11
const BSON_DBREF = 12
const BSON_CODE = 13
const BSON_SYMBOL = 14
const BSON_CODEWSCOPE = 15
const BSON_INT = 16
const BSON_TIMESTAMP = 17
const BSON_LONG = 18


type BSONObject
    _bson::Ptr{Void}

    function BSONObject(_bson::Ptr{Void})
        bson = new(_bson)
        finalizer(bson, destroy)
        return bson
    end
end

type ObjectID
    id::String
    _oid::Ptr{Void}

    function ObjectID(id::String, _oid::Ptr{Void})
        new(id, _oid)
    end
end

ObjectID(id::String) = begin
    _oid = Array(Uint8, 12)
    ccall((:bson_oid_from_string, BSON_LIB), Void, (Ptr{Void}, Ptr{Uint8}), _oid, bytestring(id))
    ObjectID(id, convert(Ptr{Void}, _oid))
end

ObjectID(_oid::Ptr{Void}) = begin
    _str = Array(Uint8, 25)
    ccall((:bson_oid_to_string, BSON_LIB), Void, (Ptr{Void}, Ptr{Uint8}), _oid, _str)
    id = bytestring(_str[1:24])
    ObjectID(id, _oid)
end

function show(io::IO, oid::ObjectID)
    print(io, "ObjectID(\"$(oid.id)\")")
end

BSONObject(dict::Dict{Any,Any}) = begin
    _bson = ccall((:bson_create, BSON_LIB), Ptr{Void}, ())
    if _bson == C_NULL
        error("Unable to create BSON object")
    end
    ccall((:bson_init, BSON_LIB), Void, (Ptr{Void},), _bson)

    build(_bson, dict)

    if ccall((:bson_finish, BSON_LIB), Int32, (Ptr{Void},), _bson) == BSON_ERROR
        error("Unable to build BSON object")
    end

    BSONObject(_bson)
end

BSONObject() = BSONObject(Dict{Any,Any}())

function show(io::IO, bson::BSONObject)
    show(io, dict(bson))
end


function dict(bson::BSONObject)
    d = Dict{Any, Any}()
    for (k,v) in bson
        if v == BSONObject || v == Array
            d[k] = dict(v)
        else
            d[k] = v
        end
    end
    return d
end

function get(bson::BSONObject, key::String)
    for (k,v) in bson
        if k == key
            return v
        end
    end
    nothing
end

## Iterator ##

start(b::BSONObject) = begin
    _iterator = ccall((:bson_iterator_create, BSON_LIB), Ptr{Void}, ())
    ccall((:bson_iterator_init, BSON_LIB), Void, (Ptr{Void}, Ptr{Void}), _iterator, b._bson)
    _iterator
end

next(b::BSONObject, _iterator) = begin
    ((key(_iterator), value(_iterator)), _iterator)
end

done(b::BSONObject, _iterator) = begin
    bson_type = ccall((:bson_iterator_next, BSON_LIB), Int32, (Ptr{Void},), _iterator)
    if bson_type == BSON_EOO
        ccall((:bson_iterator_dispose, BSON_LIB), Void, (Ptr{Void},), _iterator)
        return true
    end
    false
end

## Private methods ##

function key(_iterator::Ptr{Void})
    str = ccall((:bson_iterator_key, BSON_LIB), Ptr{Uint8}, (Ptr{Void},), _iterator)
    bytestring(str)
end

function value(_iterator::Ptr{Void})
    bson_type = ccall((:bson_iterator_type, BSON_LIB), Int32, (Ptr{Void},), _iterator)

    if BSON_DOUBLE == bson_type
        ccall((:bson_iterator_double, BSON_LIB), Float64, (Ptr{Void},), _iterator)
    elseif BSON_INT == bson_type
        ccall((:bson_iterator_int, BSON_LIB), Int32, (Ptr{Void},), _iterator)
    elseif BSON_LONG == bson_type
        ccall((:bson_iterator_long, BSON_LIB), Int64, (Ptr{Void},), _iterator)
    elseif BSON_STRING == bson_type || BSON_SYMBOL == bson_type
        _str = ccall((:bson_iterator_string, BSON_LIB), Ptr{Uint8}, (Ptr{Void},), _iterator)
        bytestring(_str)
    elseif BSON_OID == bson_type
        _oid = ccall((:bson_iterator_oid, BSON_LIB), Ptr{Void}, (Ptr{Void},), _iterator)
        ObjectID(_oid)
    elseif BSON_BOOL == bson_type
        _bool = ccall((:bson_iterator_bool, BSON_LIB), Int32, (Ptr{Void},), _iterator)
        _bool == 0 ? false : true
    elseif BSON_DATE == bson_type
        ccall((:bson_iterator_date, BSON_LIB), Int64, (Ptr{Void},), _iterator)
    elseif BSON_REGEX == bson_type
        _str = ccall((:bson_iterator_regex, BSON_LIB), Ptr{Uint8}, (Ptr{Void},), _iterator)
        Regex(bytestring(_str))
    elseif BSON_NULL == bson_type || BSON_UNDEFINED == bson_type
        nothing
    elseif BSON_OBJECT == bson_type
        _bson = ccall((:bson_create, BSON_LIB), Ptr{Void}, ())
        ccall((:bson_iterator_subobject, BSON_LIB), Void, (Ptr{Void}, Ptr{Void}), _iterator, _bson)
        BSONObject(_bson)
    elseif BSON_ARRAY == bson_type
        a = {}
        _subiterator = ccall((:bson_iterator_create, BSON_LIB), Ptr{Void}, ())
        ccall((:bson_iterator_subiterator, BSON_LIB), Void, (Ptr{Void}, Ptr{Void}), _iterator, _subiterator)
        while(ccall((:bson_iterator_next, BSON_LIB), Int32, (Ptr{Void},), _subiterator) != BSON_EOO)
            push!(a, value(_subiterator))
        end
        ccall((:bson_iterator_dispose, BSON_LIB), Void, (Ptr{Void},), _subiterator)
        a
    else
        # Not supported: 
        #   BSON_TIMESTAMP
        #   BSON_BINDATA
        #   BSON_CODE
        #   BSON_CODEWSCOPE
        #
        error("Unsupported type: $bson_type")
    end
end

function build(_bson::Ptr{Void}, dict::Dict{Any,Any})
    for (k,v) in dict
      append(_bson, k, v)
    end
end

function append(_bson::Ptr{Void}, k::String, v::Any)
    t = typeof(v)

    if ASCIIString == t || UTF8String == t
        ccall((:bson_append_string, BSON_LIB), Int32, (Ptr{Void}, Ptr{Uint8}, Ptr{Uint8}), _bson, bytestring(k), bytestring(v))
    elseif Int32 == t
        ccall((:bson_append_int, BSON_LIB), Int32, (Ptr{Void}, Ptr{Uint8}, Int32), _bson, bytestring(k), v)
    elseif Int64 == t
        ccall((:bson_append_long, BSON_LIB), Int32, (Ptr{Void}, Ptr{Uint8}, Int64), _bson, bytestring(k), v)
    elseif Float64 == t || Float32 == t
        ccall((:bson_append_double, BSON_LIB), Int32, (Ptr{Void}, Ptr{Uint8}, Float64), _bson, bytestring(k), v)
    elseif Bool == t
        ccall((:bson_append_bool, BSON_LIB), Int32, (Ptr{Void}, Ptr{Uint8}, Int32), _bson, bytestring(k), v == true ? 1 : 0)
    elseif ObjectID == t
        ccall((:bson_append_oid, BSON_LIB), Int32, (Ptr{Void}, Ptr{Uint8}, Ptr{Void}), _bson, bytestring(k), v._oid)
    elseif Dict{Any,Any} == t
        ccall((:bson_append_start_object, BSON_LIB), Int32, (Ptr{Void}, Ptr{Uint8}), _bson, bytestring(k))
        build(_bson, v)
        ccall((:bson_append_finish_object, BSON_LIB), Int32, (Ptr{Void},), _bson)
    elseif Array{Any,1} == t
        ccall((:bson_append_start_array, BSON_LIB), Int32, (Ptr{Void}, Ptr{Uint8}), _bson, bytestring(k))
        for i in 1:length(v)
            append(_bson, string(i-1), v[i])
        end
        ccall((:bson_append_finish_array, BSON_LIB), Int32, (Ptr{Void},), _bson)
    else
        # Not supported: 
        #   BSON_REGEX
        #   BSON_DATE
        #   BSON_TIMESTAMP
        #   BSON_BINDATA
        #   BSON_CODE
        #   BSON_CODEWSCOPE
        #
        error("Unsupported type: $t")
    end
end

function destroy(bson::BSONObject)
    ccall((:bson_destroy, BSON_LIB), Void, (Ptr{Void},), bson._bson)
end

end

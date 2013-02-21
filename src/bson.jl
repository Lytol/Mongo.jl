module BSON

export BSONObject,
       BSON_OK, BSON_ERROR,
       print

const BSON_LIBRARY_PATH = "/usr/local/lib/libmongoc"
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

BSONObject() = begin
  _bson = ccall((:bson_create, BSON_LIBRARY_PATH), Ptr{Void}, ())
  BSONObject(_bson)
end

print(bson::BSONObject) = ccall((:bson_print, BSON_LIBRARY_PATH), Void, (Ptr{Void},), bson._bson)

## Iterator ##
import Base.start, Base.next, Base.done

start(b::BSONObject) = begin
    _iterator = ccall((:bson_iterator_create, BSON_LIBRARY_PATH), Ptr{Void}, ())
    ccall((:bson_iterator_init, BSON_LIBRARY_PATH), Void, (Ptr{Void}, Ptr{Void}), _iterator, b._bson)
    _iterator
end

next(b::BSONObject, _iterator) = begin
    ((key(_iterator), value(_iterator)), _iterator)
end

done(b::BSONObject, _iterator) = begin
    bson_type = ccall((:bson_iterator_next, BSON_LIBRARY_PATH), Int32, (Ptr{Void},), _iterator)
    if bson_type == BSON_EOO
        ccall((:bson_iterator_dispose, BSON_LIBRARY_PATH), Void, (Ptr{Void},), _iterator)
        return true
    end
    false
end

function key(_iterator::Ptr{Void})
    str = ccall((:bson_iterator_key, BSON_LIBRARY_PATH), Ptr{Uint8}, (Ptr{Void},), _iterator)
    bytestring(str)
end

function value(_iterator::Ptr{Void})
    bson_type = ccall((:bson_iterator_type, BSON_LIBRARY_PATH), Int32, (Ptr{Void},), _iterator)

    if BSON_DOUBLE == bson_type
        ccall((:bson_iterator_double, BSON_LIBRARY_PATH), Float64, (Ptr{Void},), _iterator)
    elseif BSON_INT == bson_type
        ccall((:bson_iterator_int, BSON_LIBRARY_PATH), Int32, (Ptr{Void},), _iterator)
    elseif BSON_LONG == bson_type
        ccall((:bson_iterator_long, BSON_LIBRARY_PATH), Int64, (Ptr{Void},), _iterator)
    elseif BSON_STRING == bson_type || BSON_SYMBOL == bson_type
        _str = ccall((:bson_iterator_string, BSON_LIBRARY_PATH), Ptr{Uint8}, (Ptr{Void},), _iterator)
        bytestring(_str)
    elseif BSON_OID == bson_type
        _str = Array(Uint8, 25)
        _oid = ccall((:bson_iterator_oid, BSON_LIBRARY_PATH), Ptr{Void}, (Ptr{Void},), _iterator)
        ccall((:bson_oid_to_string, BSON_LIBRARY_PATH), Void, (Ptr{Void}, Ptr{Uint8}), _oid, _str)
        bytestring(_str)
    elseif BSON_BOOL == bson_type
        _bool = ccall((:bson_iterator_bool, BSON_LIBRARY_PATH), Int32, (Ptr{Void},), _iterator)
        _bool == 0 ? false : true
    elseif BSON_DATE == bson_type
        ccall((:bson_iterator_date, BSON_LIBRARY_PATH), Int64, (Ptr{Void},), _iterator)
    elseif BSON_REGEX == bson_type
        _str = ccall((:bson_iterator_regex, BSON_LIBRARY_PATH), Ptr{Uint8}, (Ptr{Void},), _iterator)
        Regex(bytestring(_str))
    elseif BSON_NULL == bson_type || BSON_UNDEFINED == bson_type
        nothing
    elseif BSON_OBJECT == bson_type
        _bson = ccall((:bson_create, BSON_LIBRARY_PATH), Ptr{Void}, ())
        ccall((:bson_iterator_subobject, BSON_LIBRARY_PATH), Void, (Ptr{Void}, Ptr{Void}), _iterator, _bson)
        BSONObject(_bson)
    elseif BSON_ARRAY == bson_type
        a = {}
        _subiterator = ccall((:bson_iterator_create, BSON_LIBRARY_PATH), Ptr{Void}, ())
        ccall((:bson_iterator_subiterator, BSON_LIBRARY_PATH), Void, (Ptr{Void}, Ptr{Void}), _iterator, _subiterator)
        while(ccall((:bson_iterator_next, BSON_LIBRARY_PATH), Int32, (Ptr{Void},), _subiterator) != BSON_EOO)
            push!(a, value(_subiterator))
        end
        ccall((:bson_iterator_dispose, BSON_LIBRARY_PATH), Void, (Ptr{Void},), _subiterator)
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

## Private methods ##

function destroy(bson::BSONObject)
    ccall((:bson_destroy, BSON_LIBRARY_PATH), Void, (Ptr{Void},), bson._bson)
end

end

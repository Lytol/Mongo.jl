# Helper functions for common query operators

macro modifier(name::Symbol)
  quote
    $(esc(name))(kv::Pair...) = ($(string("\$", name)) => Dict(kv))
    export $name
  end
end

@modifier query
@modifier orderby
import Base.max
import Base.min
@modifier max
@modifier min
@modifier set
@modifier inc

macro operator(name::Symbol)
  quote
    $(esc(name))(x) = Dict($(string("\$", name)) => x)
    export $name
  end
end

@operator gt
@operator lt
@operator lte
@operator gte
import Base.in
@operator in
@operator nin
@operator ne
@operator eq

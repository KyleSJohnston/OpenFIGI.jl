abstract type AbstractResponse end

struct ValuesResponse <: AbstractResponse
    values::Vector{String}
end

struct ErrorResponse <: AbstractResponse
    error::String
end

struct WarningResponse <: AbstractResponse
    warning::String
end

function responsetype(x)
    fields = propertynames(x)
    if :error in fields
        return ErrorResponse
    elseif :warning in fields
        return WarningResponse
    elseif :values in fields
        return ValuesResponse
    else
        error("Unknown object! $x")
    end
end

JSON.@choosetype AbstractResponse responsetype

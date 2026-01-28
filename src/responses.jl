abstract type AbstractResponse end

"Instrument object returned from the OpenFIGI API"
struct Instrument
    figi::String
    securityType::Union{String, Nothing}
    marketSector::Union{String, Nothing}
    exchCode::Union{String, Nothing}
    securityType2::Union{String, Nothing}
    ticker::Union{String, Nothing}
    name::Union{String, Nothing}
    shareClassFIGI::Union{String, Nothing}
    compositeFIGI::Union{String, Nothing}
    securityDescription::Union{String, Nothing}
    metadata::Union{String, Nothing}
end

"OpenFIGI API response with instruments"
@defaults struct DataResponse <: AbstractResponse
    data::Vector{Instrument}
    next::Union{Nothing, String} = nothing
    total::Union{Nothing, Int} = nothing
end

"OpenFIGI API response enumeration values"
struct ValuesResponse <: AbstractResponse
    values::Vector{String}
end

"OpenFIGI API response indicating an error with the request"
struct ErrorResponse <: AbstractResponse
    error::String
end

"OpenFIGI API response when no FIGI is found"
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
    elseif :data in fields
        return DataResponse
    else
        error("Unknown object! $x")
    end
end

JSON.@choosetype AbstractResponse responsetype

abstract type AbstractResponse end

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

struct DataResponse <: AbstractResponse
    data::Vector{Instrument}
end

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
    elseif :data in fields
        return DataResponse
    else
        error("Unknown object! $x")
    end
end

JSON.@choosetype AbstractResponse responsetype

function parse_response(response::HTTP.Response)
    @debug "parsing response..." response
    return JSON.parse(response.body, AbstractResponse)
end

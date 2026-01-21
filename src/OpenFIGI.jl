module OpenFIGI

# Functions
public set_apikey, cache_enums

# Identifiers
export Identifier, Ticker

# Properties
export ExchCode, MICCode, Currency, MarketSecDes, SecurityType, SecurityType2
export IncludeUnlistedEquities, OptionType, Strike, ContractSize, Coupon
export Expiration, Maturity, StateCode

# Structs
export MappingJob

using Dates: Date
using HTTP
using JSON
using Logging
using Scratch

const URI_BASE = "https://api.openfigi.com"
const APIKEY = Ref{Union{Nothing, String}}(nothing)
const STATUS_EXCEPTION = true  # TODO: determine correct value

"""
    set_apikey(apikey)

Sets the (global) apikey to `apikey`
"""
function set_apikey(apikey::Union{AbstractString, Nothing})
    APIKEY[] = isnothing(apikey) ? apikey : String(apikey)
end

"""
    get_apikey()

Retrieves the (global) apikey
"""
function get_apikey()
    return APIKEY[]
end

"""
    make_request_headers()
"""
function make_request_headers()::Dict{String, String}
    headers = Dict("Content-Type" => "application/json")
    apikey = get_apikey()
    if !isnothing(apikey)
        headers["X-OPENFIGI-APIKEY"] = apikey
    end
    return headers
end

include("identifiers.jl")
include("properties.jl")
include("responses.jl")
include("enumerations.jl")
include("mapping.jl")

# placeholders
function post_search()
    error("not yet implemented")
end

function post_filter()
    error("not yet implemented")
end

end # module OpenFIGI

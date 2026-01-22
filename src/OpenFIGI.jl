"""
Functionality to access the OpenFIGI API

See [the python example](https://github.com/OpenFIGI/api-examples/blob/main/python/example.py).
"""
module OpenFIGI

# Functions
public set_apikey, cache_enums
export mapping_channel, search_channel
public mapping_values  # enumerations.jl
export mapping  # mapping.jl

# Identifiers
export Identifier
export BarclaysTicker, BaseTicker, CompositeIDBBGlobal, IDBB, IDBB8Chr
export IDBBGlobal, IDBBGlobalShareClassLevel, IDBBSecNumDes, IDBBUnique, CINS
export Common, CUSIP, CUSIP8Chr, ExchangeSymbol, FullExchangeSymbol, ISIN
export Italy, SEDOL, ShortCode, Trace, Wertpapier, OCCSymbol, OPRASymbol
export Ticker, TradebookTicker, TradingSystemIdentifier, UniqueIDFutOpt
export VendorIndexCode

# Properties
export ExchCode, MICCode, Currency, MarketSecDes, SecurityType, SecurityType2
export IncludeUnlistedEquities, OptionType, Strike, ContractSize, Coupon
export Expiration, Maturity, StateCode

# Structs
export MappingJob
export DataResponse, ErrorResponse, WarningResponse

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
    return nothing
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

include("rate_limit.jl")
include("responses.jl")
include("enumerations.jl")  # requires responses
include("identifiers.jl")   # requires enumerations for validation
include("properties.jl")    # requires enumerations for validation
include("mapping.jl")
include("search.jl")
include("filter.jl")

end # module OpenFIGI

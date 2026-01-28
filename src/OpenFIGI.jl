"""
Functionality to access the OpenFIGI API

See [the python example](https://github.com/OpenFIGI/api-examples/blob/main/python/example.py).
"""
module OpenFIGI

using Compat
using Dates: Date
using HTTP
using JSON
using Logging
using Scratch

# Functions
@compat public set_apikey, cache_enums
export mapping_channel, search_channel
@compat public mapping_values  # enumerations.jl
export mapping  # mapping.jl
export search_instruments  # search.jl
export filter_instruments  # filter.jl

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
export Instrument
export DataResponse, ErrorResponse, WarningResponse, ValuesResponse


const URI_BASE = "https://api.openfigi.com"
const APIKEY = Ref{Union{Nothing, String}}(nothing)
# get_* and post_* functions are written with
# `status_exception=STATUS_EXCEPTION`. The generic expectation is to provide
# a synchronous interface in light of potentially malformed inputs. Therefore,
# `mapping_channel` and `search_channel` allow for non-2XX reponses to raise
# and close the channel. As such--a.k.a. without any kind of task recovery--
# there is no reason to treat any non-2XX responses different from one another.
# As every task is expected to produce an instance of HTTP.Response, this code
# tolerates when `fetch(task)` raises instead.
const STATUS_EXCEPTION = true

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

using .Mapping
using .Search
using .Filter

end # module OpenFIGI

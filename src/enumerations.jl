## https://www.openfigi.com/api/documentation#v3-get-mapping-values-key

"""
Supported enumeration keys for use with `values`
"""
const ALLOWABLE_KEYS = (
    "idType",
    "exchCode",
    "micCode",
    "currency",
    "marketSecDes",
    "securityType",
    "securityType2",
    "stateCode",
)

function validatekey(key::AbstractString)
    key in ALLOWABLE_KEYS || throw(ArgumentError("unexpected key of $key"))
end

function get_mapping_values(key::AbstractString)
    return HTTP.get(
        "$URI_BASE/v3/mapping/values/$key",
        make_request_headers(),
        status_exception=STATUS_EXCEPTION,
    )
end

function parse_mapping_value_response(response::HTTP.Response)
    return JSON.parse(response.body, AbstractResponse)
end

function mapping_values(key::AbstractString)
    response = get_mapping_values(key)
    return JSON.parse(response.body, AbstractResponse)
end

function read_enum_values(key::AbstractString; refresh::Bool=false)
    validatekey(key)
    filepath = joinpath(@get_scratch!("enums"), "$key.json")
    if refresh || !isfile(filepath)
        response = mapping_values(key)::ValuesResponse
        open(filepath, write=true) do io
            JSON.json(io, response.values)
        end
        return response.values
    else
        return JSON.parsefile(filepath)
    end
end

const ENUM_VALUES = Dict{String, Vector{String}}()

function enum_values(key::AbstractString; refresh::Bool=false)
    validatekey(key)
    if refresh || !haskey(ENUM_VALUES, key)
        ENUM_VALUES[key] = read_enum_values(key; refresh)
    end
    return ENUM_VALUES[key]
end

"""
    cache_enums(; refresh=false)

Caches enumeration values in a global dictionary for quick access. If
`refresh` is true, forces the enumeration values to be queried from
the API instead of loaded from the scratch space.
"""
function cache_enums(; refresh::Bool=false)
    for key in ALLOWABLE_KEYS
        _ = enum_values(key; refresh)
    end
end

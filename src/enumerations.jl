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

function handle_mapping_values_response(response::HTTP.Response)
    obj = JSON.parse(response.body, AbstractResponse)
    if obj isa ErrorResponse
        error(obj.error)
    elseif obj isa WarningResponse
        error(obj.warning)
    else
        # ValuesResponse
        return obj.values
    end
end

"""
    mapping_values(key)

Send a single API request to mapping/values/`key` to obtain enum-like values
for `key`. Used implicitly via `cache_enums`

See [`cache_enums()`](@ref)
"""
function mapping_values(key::AbstractString)
    return handle_mapping_values_response(get_mapping_values(key))
end

"""
    mapping_values(tasks, key)

Send a single API request to mapping/values/`key` respecting the rate limits
enforced by `tasks`. Equivalent to `mapping_values(key)` up to the rate limits
imposed by `tasks`.

Where possible or practical, this method is preferred.

```julia
chnl = mapping_channel() do ch
    id_values = mapping_values(ch, "idType")
end
```

See [`mapping_values(key)`](@ref)
"""
function mapping_values(tasks::Channel{Task}, key::AbstractString)
    t = @task get_mapping_values(key)
    t.sticky = false
    put!(tasks, t)
    response = fetch(t)
    return handle_mapping_values_response(response)
end

function read_enum_values(key::AbstractString; refresh::Bool=false)
    validatekey(key)
    filepath = joinpath(@get_scratch!("enums"), "$key.json")
    if refresh || !isfile(filepath)
        values = mapping_values(key)::Vector{String}
        open(filepath, write=true) do io
            JSON.json(io, values)
        end
        return values
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

struct InvalidEnumerationError <: Exception
    key::String
    value::String
end

function Base.showerror(io::IO, err::InvalidEnumerationError)
    print(io, "InvalidEnumerationError: ", err.value, " is not an enumerated value for ", err.key)
end

function validate_enum(key::String, value::String; validation_policy::Symbol=:error)
    validation_policy == :skip || validation_policy == :warning || validation_policy == :error || throw(ArgumentError("invalid policy $validation_policy"))
    if validation_policy == :skip
        return
    end

    possible_values = enum_values(key)
    if value ∉ possible_values
        if validation_policy == :error
            throw(InvalidEnumerationError(key, value))
        else
            @warn "$value is not an enumerated value for $key"
        end
    end

end

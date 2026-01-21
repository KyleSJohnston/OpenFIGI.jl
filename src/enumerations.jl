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

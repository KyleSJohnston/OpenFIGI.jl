module OpenFIGI

public set_apikey

const APIKEY = Ref{Union{Nothing, String}}(nothing)

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


end # module OpenFIGI

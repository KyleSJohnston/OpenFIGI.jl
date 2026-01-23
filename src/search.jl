"""
    post_search(query, properties...; start)

Submits `query` as a POST request to the search endpoint
"""
function post_search(query::String, properties::AbstractProperty...; start::Union{Nothing, String}=nothing)
    obj = Dict(
        "query" => query,
        [convert(Pair, p) for p in properties]...
    )
    if !isnothing(start)
        obj["start"] = start
    end
    return HTTP.post(
        "$URI_BASE/v3/search",
        make_request_headers(),
        JSON.json(obj),
        status_exception=STATUS_EXCEPTION,
    )
end

"""
    handle_search_response(response)

Parses `response` as an AbstractResponse instance
"""
function handle_search_response(response::HTTP.Response)
    return JSON.parse(response.body, AbstractResponse)
end

function search(query::String, properties::AbstractProperty...)::Vector{Instrument}
    response = handle_search_response(post_search(query, properties...))
    if response isa ErrorResponse
        error(response.error)
    end
    return response.data
end

function search(tasks::Channel{Task}, query::String, properties::AbstractProperty...)::Vector{Instrument}
    results = Instrument[]

    # first request
    t = @task post_search(query, properties...)
    t.sticky = false
    put!(tasks, t)
    response = handle_search_response(fetch(t))
    if response isa ErrorResponse
        error(response.error)
    else
        append!(results, response.data)
    end

    # subsequent requests
    while !isnothing(response.next)
        t = @task post_search(query, properties...; start=response.next)
        t.sticky = false
        put!(tasks, t)
        response = handle_search_response(fetch(t))
        if response isa ErrorResponse
            error(response.error)
        else
            append!(results, response.data)
        end
    end

    return results
end

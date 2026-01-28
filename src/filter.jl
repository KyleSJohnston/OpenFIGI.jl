module Filter

using HTTP
using JSON
using ..OpenFIGI: AbstractProperty, AbstractResponse, DataResponse, ErrorResponse, Instrument, make_request_headers, STATUS_EXCEPTION, URI_BASE

export instrument_filter

"""
    post(query, properties...; start)

Submits `query` as a POST request to the filter endpoint
"""
function post(
    properties::AbstractProperty...;
    query::Union{Nothing, String}=nothing,
    start::Union{Nothing, String}=nothing,
)
    obj = Dict(
        [convert(Pair, p) for p in properties]...
    )
    if !isnothing(query)
        obj["query"] = query
    end
    if !isnothing(start)
        obj["start"] = start
    end
    return HTTP.post(
        "$URI_BASE/v3/filter",
        make_request_headers(),
        JSON.json(obj),
        status_exception=STATUS_EXCEPTION,
    )
end

"""
    handle_response(response)

Parses `response` as an AbstractResponse instance
"""
function handle_response(response::HTTP.Response)
    return JSON.parse(response.body, AbstractResponse)
end

"""
    instrument_filter(query, properties...)

Sends a single filter query to the OpenFIGI API

# Caveats
- This method is primarily for testing.
- This method does *not* support paginated responses, so no more than 100 results are returned.
- This method does *not* attempt to manage requests to comply with rate limits.

Use [`instrument_filter(tasks, query, properties...)`](@ref) instead.
"""
function instrument_filter(properties::AbstractProperty...; query::Union{Nothing, String}=nothing)::Vector{Instrument}
    response = handle_response(post(query, properties...))
    if response isa ErrorResponse
        error(response.error)
    end
    return response.data
end

function _response(task::Task)::DataResponse
    response = handle_response(fetch(task))
    if response isa ErrorResponse
        error(response.error)
    end
    return response
end

function _add_results!(results::Channel{Instrument}, task::Task)
    response = fetch(task)::DataResponse
    for i in response.data
        put!(results, i)
    end
end

function _next(task::Task, search_args...; query)
    response = fetch(task)::DataResponse
    if !isnothing(response.next)
        t = _filter(search_args...; query, start=response.next)
        wait(t)
    end
end

function _filter(
    tasks::Channel{Task},
    results::Channel{Instrument},
    properties::AbstractProperty...;
    query::Union{Nothing, String}=nothing,
    start::Union{Nothing, String}=nothing,
)::Task
    t = @task post(properties...; query, start)
    t.sticky = false
    put!(tasks, t)
    parsing_task = Threads.@spawn _response(t)
    output_task = Threads.@spawn _add_results!(results, parsing_task)
    next_task = Threads.@spawn _next(parsing_task, tasks, results, properties...; query)
    return Threads.@spawn waitall([output_task, next_task]; failfast=true)
end

"""
    instrument_filter(tasks, results, properties...; [query])

Spawn a `instrument_search` task that processes `query` in batches and populates `results`

# Arguments
- `tasks::Channel{Task}`: a rate-limited channel for scheduling API requests (see [`search_channel()`](@ref))
- `results::Channel{Instrument}`: the search results in order of return
- `properties::AbstractProperty...`: optional properties for limiting results
- `query::String`: optional filter keywords

The task returned from this method is bound to `results`.
"""
function instrument_filter(
    tasks::Channel{Task},
    results::Channel{Instrument},
    properties::AbstractProperty...;
    query::Union{Nothing, String}=nothing,
)::Task
    t = _filter(tasks, results, properties...; query)
    bind(results, t)
    return t
end

"""
    instrument_filter(tasks, query, properties...)

Submits `query` to the filter endpoint as scheduled by `tasks`

# Arguments
- `tasks::Channel{Task}`: a rate-limited channel for scheduling API requests (see [`search_channel()`](@ref))
- `properties::AbstractProperty...`: optional properties for limiting results
- `query::String`: search keywords

Internally, this method uses [`instrument_filter(tasks, results, properties...; query)`](@ref)
for the batching logic.
"""
function instrument_filter(
    tasks::Channel{Task},
    properties::AbstractProperty...;
    query::Union{Nothing, String}=nothing,
)::Vector{Instrument}
    results_channel = Channel{Instrument}()
    search_task = instrument_filter(tasks, results_channel, properties...; query)
    results = collect(results_channel)
    wait(search_task)
    return results
end

end  # module

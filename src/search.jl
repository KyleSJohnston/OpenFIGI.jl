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

function _response(task::Task)::DataResponse
    response = handle_search_response(fetch(task))
    if response isa ErrorResponse
        error(response.error)
    end
    return response
end

function _add_search_results!(results::Channel{Instrument}, task::Task)
    response = fetch(task)::DataResponse
    for i in response.data
        put!(results, i)
    end
end

function _next_search(task::Task, search_args...)
    response = fetch(task)::DataResponse
    if !isnothing(response.next)
        t = _search(search_args...; start=response.next)
        wait(t)
    end
end

function _search(tasks::Channel{Task}, results::Channel{Instrument}, query::String, properties::AbstractProperty...; start::Union{Nothing, String}=nothing)::Task
    t = @task post_search(query, properties...; start)
    t.sticky = false
    put!(tasks, t)
    parsing_task = Threads.@spawn _response(t)
    output_task = Threads.@spawn _add_search_results!(results, parsing_task)
    next_task = Threads.@spawn _next_search(parsing_task, tasks, results, query, properties...)
    return Threads.@spawn waitall([output_task, next_task]; failfast=true)
end

function search(tasks::Channel{Task}, results::Channel{Instrument}, query::String, properties::AbstractProperty...)::Task
    t = _search(tasks, results, query, properties...)
    bind(results, t)
    return t
end


function search(tasks::Channel{Task}, query::String, properties::AbstractProperty...)::Vector{Instrument}
    results_channel = Channel{Instrument}()
    search_task = search(tasks, results_channel, query, properties...)
    results = collect(results_channel)
    wait(search_task)
    return results
end

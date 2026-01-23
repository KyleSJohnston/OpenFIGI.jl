## https://www.openfigi.com/api/documentation#v3-post-mapping

"""
    MappingJob(identifier, properties...)

A request for mapping from `identifier` to FIGIs

# Arguments
- `identifier::Identifier`: an identifier to map to FIGI
- `properties::AbstractProperty...`: optional properties for limiting results

# Examples

```jldoctest
julia> MappingJob(Ticker("NVDA"), ExchCode("US"), SecurityType2("Common Stock"))
MappingJob(Identifier("TICKER", "NVDA"), (ExchCode("US"), SecurityType2("Common Stock")))

julia> MappingJob(IDBBGlobal("BBG000BLNNH6"))
MappingJob(Identifier("ID_BB_GLOBAL", "BBG000BLNNH6"), ())
```

See Request Format for the [mapping endpoint](https://www.openfigi.com/api/documentation#v3-post-mapping).
"""
struct MappingJob
    identifier::Identifier
    properties::Tuple{Vararg{AbstractProperty}}
    function MappingJob(identifier::Identifier, properties::AbstractProperty...)
        new(identifier, properties)
    end
end

function JSON.lower(job::MappingJob)
    return Dict(
        "idType" => job.identifier.idType,
        "idValue" => job.identifier.idValue,
        [convert(Pair, p) for p in job.properties]...
    )
end

# https://www.openfigi.com/api/documentation#rate-limits
maxjobs() = isnothing(get_apikey()) ? 10 : 100

"""
    post_mapping(jobs)

Submits `jobs` as a POST request to the mapping endpoint
"""
function post_mapping(jobs::Vector{MappingJob})
    length(jobs) <= maxjobs() || throw(ArgumentError("too many jobs: $(length(jobs))"))
    return HTTP.post(
        "$URI_BASE/v3/mapping",
        make_request_headers(),
        JSON.json(jobs),
        status_exception=STATUS_EXCEPTION,
    )
end

"""
    handle_mapping_response(response)

Parses `response` as a vector of AbstractResponse instances
"""
function handle_mapping_response(response::HTTP.Response)
    return JSON.parse(response.body, Vector{AbstractResponse})
end

"""
    mapping(jobs)

Makes a single mapping request from `jobs` to the OpenFIGI API

While this method works fine for a single request, [`mapping(tasks, jobs)`](@ref)
is preferred for most use cases for the convenience of batching and abiding by
the rate limits.
"""
function mapping(jobs::Vector{MappingJob})::Vector{<:AbstractResponse}
    return handle_mapping_response(post_mapping(jobs))
end

function _add_results!(results::Channel{<:AbstractResponse}, tasks::Vector{Task})
    for t in tasks
        response = fetch(t)
        for r in handle_mapping_response(response)
            put!(results, r)
        end
    end
end

"""
    mapping(tasks, jobs, results)

Spawn a `mapping` task that processes `jobs` in batches and populates 

# Arguments
- `tasks::Channel{Task}`: a rate-limited channel for scheduling API requests (see [`mapping_channel()`](@ref))
- `jobs::Channel{MappingJob}`: the jobs to send to the mapping endpoint
- `results::Channel{<:AbstractResponse}`: the mapping results in the same order as `jobs`

The task returned from this method is bound to `results`. If one of the batches
should error, there will be fewer items in `results` than `jobs`. To detect the
error state, simply `wait` on the task after consuming the values in `results`.
"""
function mapping(tasks::Channel{Task}, jobs::Channel{MappingJob}, results::Channel{<:AbstractResponse})::Task
    batch_size = maxjobs()
    @debug "mapping jobs from a channel in batches of $batch_size"
    local_tasks = Task[]

    batch_jobs = MappingJob[]
    for job in jobs
        if length(batch_jobs) == batch_size
            @debug "batch is ready"
            t = @task post_mapping(copy(batch_jobs))
            t.sticky = false
            push!(local_tasks, t)
            put!(tasks, t)
            empty!(batch_jobs)
            @debug "batch submitted"
        end
        push!(batch_jobs, job)
    end
    @debug "final batch"
    t = @task post_mapping(batch_jobs)
    t.sticky = false
    push!(local_tasks, t)
    put!(tasks, t)
    @debug "final batch submitted"

    results_task = Threads.@spawn _add_results!(results, local_tasks)
    bind(results, results_task)
    return results_task
end

"""
    mapping(tasks, jobs)

Submits `jobs` to the mapping endpoint as scheduled by `tasks`

# Arguments
- `tasks::Channel{Task}`: a rate-limited channel for scheduling API requests (see [`mapping_channel()`](@ref))
- `jobs::Vector{MappingJob}`: the jobs to send to the mapping endpoint

Internally, this method uses [`mapping(tasks, jobs, results)`](@ref) for the
batching logic.
"""
function mapping(tasks::Channel{Task}, jobs::Vector{MappingJob})::Vector{AbstractResponse}
    # prepare results
    results_channel = Channel{AbstractResponse}(maxjobs())
    results_task = Threads.@spawn collect(results_channel)

    # prepare jobs
    job_channel = Channel{MappingJob}(maxjobs(); spawn=true) do chnl
        for job in jobs
            put!(chnl, job)
        end
    end

    # queue mapping
    t = mapping(tasks, job_channel, results_channel)

    results = fetch(results_task)
    wait(t)  # raise any errors encountered
    return results
end

"""
    mapping(tasks, job)

Submits `job` to the mapping endpoint as scheduled by `tasks`

# Arguments
- `tasks::Channel{Task}`: a rate-limited channel for scheduling API requests (see [`mapping_channel()`](@ref))
- `job::MappingJob`: the job to send to the mapping endpoint

Internally, this method uses [`mapping(tasks, jobs)`](@ref).
"""
function mapping(tasks::Channel{Task}, job::MappingJob)::AbstractResponse
    return only(mapping(tasks, [job]))
end

"""
    mapping(tasks, identifier, properties...)

Submits a `MappingJob` constructed from `identifer` and `properties` to the
mapping endpoint as scheduled by `tasks`

# Arguments
- `tasks::Channel{Task}`: a rate-limited channel for scheduling API requests (see [`mapping_channel()`](@ref))
- `job::MappingJob`: the job to send to the mapping endpoint

Internally, this method uses [`mapping(tasks, jobs)`](@ref).
"""
function mapping(tasks::Channel{Task}, identifier::Identifier, properties::AbstractProperty...)::AbstractResponse
    return mapping(tasks, MappingJob(identifier, properties...))
end

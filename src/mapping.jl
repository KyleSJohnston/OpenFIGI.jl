## https://www.openfigi.com/api/documentation#v3-post-mapping

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

function post_mapping(jobs::Vector{MappingJob})
    length(jobs) <= maxjobs() || throw(ArgumentError("too many jobs: $(length(jobs))"))
    return HTTP.post(
        "$URI_BASE/v3/mapping",
        make_request_headers(),
        JSON.json(jobs),
        status_exception=STATUS_EXCEPTION,
    )
end

function handle_mapping_response(response::HTTP.Response)
    return JSON.parse(response.body, Vector{AbstractResponse})
end

# TODO: document this
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

# TODO: document this
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

# TODO: document this
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
    mapping(tasks, job_channel, results_channel)

    return fetch(results_task)
end

# TODO: document this
function mapping(tasks::Channel{Task}, job::MappingJob)::AbstractResponse
    return only(mapping(tasks, [job]))
end

# TODO: document this
function mapping(tasks::Channel{Task}, identifier::Identifier, properties::AbstractProperty...)::AbstractResponse
    return mapping(tasks, MappingJob(identifier, properties...))
end

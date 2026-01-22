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

function mapping(jobs::Vector{MappingJob})
    return handle_mapping_response(post_mapping(jobs))
end

function mapping(tasks::Channel{Task}, jobs::Vector{MappingJob})
    t = @task post_mapping(jobs)
    t.sticky = false
    put!(tasks, t)
    response = fetch(t)
    return handle_mapping_response(response)
end

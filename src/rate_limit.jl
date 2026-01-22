function _task_loop(tasks::Channel{Task})
    # TODO: add flag to wait until `reset_time` for opening a new channel afterwards
    isopen(tasks) || throw(ArgumentError("`tasks` channel is not open"))

    policy = ""
    limit = typemax(Int)
    limit_remaining = typemax(Int)
    reset_time = Inf
    
    for task in tasks
        @debug "new task"
        if limit_remaining == 0
            # schedule it in the next interval
            @debug "interval is full; waiting for next interval to start"
            sleep(reset_time - time() + 1)  # wait an extra second
        end
        @debug "scheduling task..."
        schedule(task)
        @debug "awaiting response..."
        # `fetch(task)`
        response = fetch(task)::HTTP.Response
        @debug "response arrived"
        arrival_time = time()
        headers = Dict(response.headers)

        # Verify that ratelimit-policy is consistent with expectations.
        if haskey(headers, "ratelimit-policy")
            if policy == ""
                policy = headers["ratelimit-policy"]
            elseif policy != headers["ratelimit-policy"]
                @warn "change in ratelimit-policy" policy headers["ratelimit-policy"]
                policy = headers["ratelimit-policy"]
            end
        else
            @warn "ratelimit-policy not specified in response headers" headers
        end

        # Update limit parameters from headers.
        limit = parse(Int, headers["ratelimit-limit"])
        limit_remaining = parse(Int, headers["ratelimit-remaining"])
        time_to_reset = parse(Float64, headers["ratelimit-reset"])
        reset_time = arrival_time + time_to_reset

        @debug "waiting for a new task" limit limit_remaining time_to_reset
    end
end

"""
Exception signifying an issue in complying with the rate limit
"""
struct RateLimitException <: Exception
    cause::Exception
end

function Base.showerror(io::IO, err::RateLimitException)
    print(io, "RateLimitException: issue complying with the rate limit")
    print(io, "    Cause: ", err.cause)
end


function _error_remaining(err::Exception, tasks::Channel{Task})
    for task in tasks
        # Raise a `RateLimitException` for all remaining tasks, allowing
        # `fetch` to return with the exception instead of blocking.
        schedule(task, RateLimitException(err); error=true)
    end
end

"""
    rate_limit(tasks)

Schedules tasks from `tasks` at a rate determined by response headers

Some of the downstream code relies on the queue-like nature of the `Channel`.
Without substantially more information about each `Task` in `tasks` and their
interdependencies, there's no way to know whether any remaining task is still
valid. We raise a `RateLimitException` in each of the remaining tasks to
indicate that the task could not be completed and to explain the cause.

See also [OpenFIGI Rate Limits](https://www.openfigi.com/api/documentation#rate-limits).
"""
function rate_limit(tasks::Channel{Task})
    try
        @debug "starting task loop"
        _task_loop(tasks)
    catch err
        @warn "Exception encountered with `rate_limit`; closing channel" err
        close(tasks)  # no additional tasks
        @warn "Cancelling remaining tasks"
        _error_remaining(err, tasks)
        rethrow()
    else
        @debug "task loop done"
    end
end

function mapping_channel()::Channel{Task}
    size = isnothing(OpenFIGI.get_apikey()) ? 25 : 250
    return Channel{Task}(rate_limit, size; spawn=true)
end

function mapping_channel(f::Function)
    chnl = mapping_channel()
    try
        f(chnl)
    finally
        close(chnl)
    end
end

function search_channel()::Channel{Task}
    size = isnothing(OpenFIGI.get_apikey()) ? 5 : 20
    return Channel{Task}(rate_limit, size; spawn=true)
end

function search_channel(f::Function)
    chnl = search_channel()
    try
        f(chnl)
    finally
        close(chnl)
    end
end
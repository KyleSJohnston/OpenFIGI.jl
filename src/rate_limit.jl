function _task_loop(tasks::Channel{Task}, wait_reset::Bool=false)
    if !isopen(tasks)
        @warn "`tasks` channel is not open"
    end

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

    if wait_reset
        if isinf(reset_time)
            @warn "reset_time is inf; not waiting for the interval reset"
        else
            @debug "waiting for the interval to reset before returning" reset_time
            sleep(reset_time - time() + 1)  # wait an extra second
            @debug "done waiting"
        end
    end
    return nothing
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
    rate_limit(tasks, wait_reset=false)

Schedules tasks from `tasks` at a rate determined by response headers

If `wait_reset` is true, this function will not return until the final interval
has finished. This may be useful when performing searches after mappings or
vice versa with a new channel that expects to start in a new interval.

Some of the downstream code relies on the queue-like nature of the `Channel`.
Without substantially more information about each `Task` in `tasks` and their
interdependencies, there's no way to know whether any remaining task is still
valid. We raise a `RateLimitException` in each of the remaining tasks to
indicate that the task could not be completed and to explain the cause.

See also [OpenFIGI Rate Limits](https://www.openfigi.com/api/documentation#rate-limits).
"""
function rate_limit(tasks::Channel{Task}, wait_reset::Bool=false)
    try
        @debug "starting task loop"
        _task_loop(tasks, wait_reset)
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

"""
    mapping_channel()

Creates a new channel for mapping tasks

The resulting `Channel{Task}` instance is sized to hold one interval of request
tasks and is bound to a new `Task` spawned to rate-limit the channel.
"""
function mapping_channel()::Channel{Task}
    size = isnothing(OpenFIGI.get_apikey()) ? 25 : 250
    return Channel{Task}(rate_limit, size; spawn=true)
end

"""
    mapping_channel(f, wait_reset=false)

Creates a channel for mapping tasks, runs `f` on that channel, and finally
closes the channel.

```julia
nvda = search_channel() do ch
    return mapping(ch, Ticker("NVDA"), ExchCode("US"), SecurityType2("Common Stock"))
end
```

See [`mapping_channel()`](@ref)
"""
function mapping_channel(f::Function, wait_reset::Bool=false)
    size = isnothing(OpenFIGI.get_apikey()) ? 25 : 250
    taskref = Ref{Task}()
    chnl = Channel{Task}(ch -> rate_limit(ch, wait_reset), size; taskref, spawn=true)
    try
        return f(chnl)
    finally
        close(chnl)
        if wait_reset
            wait(taskref[]; throw=false)
        end
    end
end

"""
    search_channel()

Creates a channel for search or filter tasks

The resulting `Channel{Task}` instance is sized to hold one interval of search
or filter tasks and is bound to a new `Task` spawned to rate-limit the channel.
"""
function search_channel()::Channel{Task}
    size = isnothing(OpenFIGI.get_apikey()) ? 5 : 20
    return Channel{Task}(rate_limit, size; spawn=true)
end

"""
    search_channel(f, wait_reset=false)

Creates a channel for search or filter tasks, runs `f` on that channel, and
finally closes the channel.

See [`search_channel()`](@ref)
"""
function search_channel(f::Function, wait_reset::Bool=false)
    size = isnothing(OpenFIGI.get_apikey()) ? 5 : 20
    taskref = Ref{Task}()
    chnl = Channel{Task}(ch -> rate_limit(ch, wait_reset), size; taskref, spawn=true)
    try
        return f(chnl)
    finally
        close(chnl)
        if wait_reset
            wait(taskref[]; throw=false)
        end
    end
end

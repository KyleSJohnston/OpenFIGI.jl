
abstract type AbstractProperty end

propertykey(::AbstractProperty) = error("subtypes of AbstractProperty must implement `propertykey`")
propertyvalue(::AbstractProperty) = error("subtypes of AbstractProperty must implement `propertyvalue`")
Base.convert(::Type{Pair}, p::AbstractProperty) = Pair(propertykey(p), propertyvalue(p))


"""
    ExchCode(value)
"""
struct ExchCode <: AbstractProperty
    value::String

    function ExchCode(value::String; validation_policy::Symbol=:error)
        validate_enum("exchCode", value; validation_policy)
        new(value)
    end
end
propertykey(::ExchCode) = "exchCode"
propertyvalue(p::ExchCode) = p.value


"""
    MICCode(value)
"""
struct MICCode <: AbstractProperty
    value::String

    function MICCode(value::String; validation_policy::Symbol=:error)
        validate_enum("micCode", value; validation_policy)
        new(value)
    end
end
propertykey(::MICCode) = "micCode"
propertyvalue(p::MICCode) = p.value

"""
    Currency(value)
"""
struct Currency <: AbstractProperty
    value::String

    function Currency(value::String; validation_policy::Symbol=:error)
        validate_enum("currency", value; validation_policy)
        new(value)
    end
end
propertykey(::Currency) = "currency"
propertyvalue(p::Currency) = p.value

"""
    MarketSecDes(value)
"""
struct MarketSecDes <: AbstractProperty
    value::String

    function MarketSecDes(value::String; validation_policy::Symbol=:error)
        validate_enum("marketSecDes", value; validation_policy)
        new(value)
    end
end
propertykey(::MarketSecDes) = "marketSecDes"
propertyvalue(p::MarketSecDes) = p.value

"""
    SecurityType(value)
"""
struct SecurityType <: AbstractProperty
    value::String

    function SecurityType(value::String; validation_policy::Symbol=:error)
        validate_enum("securityType", value; validation_policy)
        new(value)
    end
end
propertykey(::SecurityType) = "securityType"
propertyvalue(p::SecurityType) = p.value

"""
    SecurityType2(value)
"""
struct SecurityType2 <: AbstractProperty
    value::String

    function SecurityType2(value::String; validation_policy::Symbol=:error)
        validate_enum("securityType2", value; validation_policy)
        new(value)
    end
end
propertykey(::SecurityType2) = "securityType2"
propertyvalue(p::SecurityType2) = p.value

"""
    IncludeUnlistedEquities(value)
"""
struct IncludeUnlistedEquities <: AbstractProperty
    value::Bool
end
propertykey(::IncludeUnlistedEquities) = "includeUnlistedEquities"
propertyvalue(p::IncludeUnlistedEquities) = p.value

"""
    OptionType(value)
"""
struct OptionType <: AbstractProperty
    value::String

    function OptionType(value::String; validation_policy::Symbol=:error)
        validation_policy == :skip || validation_policy == :warning || validation_policy == :error || throw(ArgumentError("invalid policy $validation_policy"))

        is_valid = validation_policy == :skip || value == "Call" || value == "Put"

        if !is_valid
            if validation_policy == :error
                throw(ArgumentError("Invalid OptionType $value"))
            else
                @warn "Invalid OptionType $value"
            end
        end
        new(value)
    end
end
propertykey(::OptionType) = "optionType"
propertyvalue(p::OptionType) = p.value

struct Interval{T} <: AbstractProperty
    key::String
    lbound::Union{Nothing, T}
    ubound::Union{Nothing, T}
    function Interval{T}(key::String, lbound::Union{Nothing, T}, ubound::Union{Nothing, T}) where {T}
        isnothing(lbound) && isnothing(ubound) && throw(ArgumentError("Interval requires either lbound or ubound"))
        isnothing(lbound) || isnothing(ubound) || (lbound <= ubound) || throw(ArgumentError("lbound > ubound"))
        new(key, lbound, ubound)
    end
end
Interval(::String, ::Nothing, ::Nothing) = throw(ArgumentError("Interval requires either lbound or ubound"))
Interval(key::String, lbound::T, ubound::T) where {T} = Interval{T}(key, lbound, ubound)
Interval(key::String, lbound::T, ubound::Nothing) where {T} = Interval{T}(key, lbound, ubound)
Interval(key::String, lbound::Nothing, ubound::T) where {T} = Interval{T}(key, lbound, ubound)
function Interval(key::String, lbound::Number, ubound::Number)
    lbound, ubound = promote(lbound, ubound)
    T = typeof(lbound)
    return Interval{T}(key, lbound, ubound)
end

propertykey(interval::Interval) = interval.key
propertyvalue(interval::Interval) = [interval.lbound, interval.ubound]

# TODO: restrict types
"""
    Strike(lbound, ubound)
"""
Strike(args...) = Interval("strike", args...)

"""
    ContractSize(lbound, ubound)
"""
ContractSize(args...) = Interval("contractSize", args...)

"""
    Coupon(lbound, ubound)
"""
Coupon(args...) = Interval("coupon", args...)

"""
    Expiration(lbound, ubound)
"""
Expiration(args...) = Interval{Date}("expiration", args...)

"""
    Maturity(lbound, ubound)
"""
Maturity(args...) = Interval{Date}("maturity", args...)

"""
    StateCode(value)
"""
struct StateCode <: AbstractProperty
    value::String

    function StateCode(value::String; validation_policy::Symbol=:error)
        validate_enum("stateCode", value; validation_policy)
        new(value)
    end
end
propertykey(::StateCode) = "stateCode"
propertyvalue(p::StateCode) = p.value


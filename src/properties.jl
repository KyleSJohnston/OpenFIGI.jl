
abstract type AbstractProperty end

propertykey(::AbstractProperty) = error("subtypes of AbstractProperty must implement `propertykey`")
propertyvalue(::AbstractProperty) = error("subtypes of AbstractProperty must implement `propertyvalue`")
Base.convert(Pair, p::AbstractProperty) = Pair(propertykey(p), propertyvalue(p))


# TODO: add validation

struct ExchCode <: AbstractProperty
    value::String
end
propertykey(::ExchCode) = "exchCode"
propertyvalue(p::ExchCode) = p.value


struct MICCode <: AbstractProperty
    value::String
end
propertykey(::MICCode) = "micCode"
propertyvalue(p::MICCode) = p.value

struct Currency <: AbstractProperty
    value::String
end
propertykey(::Currency) = "currency"
propertyvalue(p::Currency) = p.value

struct MarketSecDes <: AbstractProperty
    value::String
end
propertykey(::MarketSecDes) = "marketSecDes"
propertyvalue(p::MarketSecDes) = p.value

struct SecurityType <: AbstractProperty
    value::String
end
propertykey(::SecurityType) = "securityType"
propertyvalue(p::SecurityType) = p.value

struct SecurityType2 <: AbstractProperty
    value::String
end
propertykey(::SecurityType2) = "securityType2"
propertyvalue(p::SecurityType2) = p.value

struct IncludeUnlistedEquities <: AbstractProperty
    value::Bool
end
propertykey(::IncludeUnlistedEquities) = "includeUnlistedEquities"
propertyvalue(p::IncludeUnlistedEquities) = p.value

struct OptionType <: AbstractProperty
    value::String
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
Interval(key::String, lbound::T, ubound::Nothing) where {T} = Interval{T}(key, lbound, ubound)
Interval(key::String, lbound::Nothing, ubound::T) where {T} = Interval{T}(key, lbound, ubound)
# TODO: consider promote(lbound, ubound)

propertykey(interval::Interval) = interval.key
propertyvalue(interval::Interval) = [interval.lbound, interval.ubound]

# TODO: restrict types
const Strike = Base.Fix1(Interval, "strike")
const ContractSize = Base.Fix1(Interval, "contractSize")
const Coupon = Base.Fix1(Interval, "coupon")
const Expiration = Base.Fix1(Interval{Date}, "expiration")
const Maturity = Base.Fix1(Interval{Date}, "maturity")

struct StateCode <: AbstractProperty
    value::String
end
propertykey(::StateCode) = "stateCode"
propertyvalue(p::StateCode) = p.value


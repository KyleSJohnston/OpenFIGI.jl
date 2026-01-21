## https://www.openfigi.com/api/documentation#v3-id-type-values

struct Identifier
    idType::String
    idValue::String
end

const Ticker = Base.Fix1(Identifier, "TICKER")

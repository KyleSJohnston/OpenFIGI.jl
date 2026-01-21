## https://www.openfigi.com/api/documentation#v3-id-type-values

struct Identifier
    idType::String
    idValue::String

    function Identifier(idType::String, idValue::String; validation_policy::Symbol=:error)
        validate_enum("idType", idType; validation_policy)
        new(idType, idValue)
    end
end

const Ticker = Base.Fix1(Identifier, "TICKER")

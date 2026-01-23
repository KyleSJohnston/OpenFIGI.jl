## https://www.openfigi.com/api/documentation#v3-id-type-values

"""
    Identifier(idType, idValue)

An identifier, as specified by a type an a value for that type

Valid identifiers are documented [here](https://www.openfigi.com/api/documentation#v3-id-type-values).
"""
struct Identifier
    idType::String
    idValue::String

    function Identifier(idType::String, idValue::String; validation_policy::Symbol=:error)
        validate_enum("idType", idType; validation_policy)
        new(idType, idValue)
    end
end

"""
    BarclaysTicker(value)

See [`Identifier`](@ref)
"""
BarclaysTicker = Base.Fix1(Identifier, "BARCLAYS_TICKER")

"""
    BaseTicker(value)

See [`Identifier`](@ref)
"""
BaseTicker = Base.Fix1(Identifier, "BASE_TICKER")

"""
    CompositeIDBBGlobal(value)

See [`Identifier`](@ref)
"""
CompositeIDBBGlobal = Base.Fix1(Identifier, "COMPOSITE_ID_BB_GLOBAL")

"""
    IDBB(value)

See [`Identifier`](@ref)
"""
IDBB = Base.Fix1(Identifier, "ID_BB")

"""
    IDBB8Chr(value)

See [`Identifier`](@ref)
"""
IDBB8Chr = Base.Fix1(Identifier, "ID_BB_8_CHR")

"""
    IDBBGlobal(value)

See [`Identifier`](@ref)
"""
IDBBGlobal = Base.Fix1(Identifier, "ID_BB_GLOBAL")

"""
    IDBBGlobalShareClassLevel(value)

See [`Identifier`](@ref)
"""
IDBBGlobalShareClassLevel = Base.Fix1(Identifier, "ID_BB_GLOBAL_SHARE_CLASS_LEVEL")

"""
    IDBBSecNumDes(value)

See [`Identifier`](@ref)
"""
IDBBSecNumDes = Base.Fix1(Identifier, "ID_BB_SEC_NUM_DES")

"""
    IDBBUnique(value)

See [`Identifier`](@ref)
"""
IDBBUnique = Base.Fix1(Identifier, "ID_BB_UNIQUE")

"""
    CINS(value)

See [`Identifier`](@ref)
"""
CINS = Base.Fix1(Identifier, "ID_CINS")

"""
    Common(value)

See [`Identifier`](@ref)
"""
Common = Base.Fix1(Identifier, "ID_COMMON")


"""
    CUSIP(value)

See [`Identifier`](@ref)
"""
CUSIP = Base.Fix1(Identifier, "ID_CUSIP")

"""
    CUSIP8Chr(value)

See [`Identifier`](@ref)
"""
CUSIP8Chr = Base.Fix1(Identifier, "ID_CUSIP_8_CHR")

"""
    ExchangeSymbol(value)

See [`Identifier`](@ref)
"""
ExchangeSymbol = Base.Fix1(Identifier, "ID_EXCH_SYMBOL")

"""
    FullExchangeSymbol(value)

See [`Identifier`](@ref)
"""
FullExchangeSymbol = Base.Fix1(Identifier, "ID_FULL_EXCHANGE_SYMBOL")

"""
    ISIN(value)

See [`Identifier`](@ref)
"""
ISIN = Base.Fix1(Identifier, "ID_ISIN")

"""
    Italy(value)

See [`Identifier`](@ref)
"""
Italy = Base.Fix1(Identifier, "ID_ITALY")

"""
    SEDOL(value)

See [`Identifier`](@ref)
"""
SEDOL = Base.Fix1(Identifier, "ID_SEDOL")

"""
    ShortCode(value)

See [`Identifier`](@ref)
"""
ShortCode = Base.Fix1(Identifier, "ID_SHORT_CODE")

"""
    Trace(value)

See [`Identifier`](@ref)
"""
Trace = Base.Fix1(Identifier, "ID_TRACE")

"""
    Wertpapier(value)

See [`Identifier`](@ref)
"""
Wertpapier = Base.Fix1(Identifier, "ID_WERTPAPIER")

"""
    OCCSymbol(value)

See [`Identifier`](@ref)
"""
OCCSymbol = Base.Fix1(Identifier, "OCC_SYMBOL")

"""
    OPRASymbol(value)

See [`Identifier`](@ref)
"""
OPRASymbol = Base.Fix1(Identifier, "OPRA_SYMBOL")

"""
    Ticker(value)

See [`Identifier`](@ref)
"""
Ticker = Base.Fix1(Identifier, "TICKER")

"""
    TradebookTicker(value)

See [`Identifier`](@ref)
"""
TradebookTicker = Base.Fix1(Identifier, "TRADEBOOK_TICKER")

"""
    TradingSystemIdentifier(value)

See [`Identifier`](@ref)
"""
TradingSystemIdentifier = Base.Fix1(Identifier, "TRADING_SYSTEM_IDENTIFIER")

"""
    UniqueIDFutOpt(value)

See [`Identifier`](@ref)
""" 
UniqueIDFutOpt = Base.Fix1(Identifier, "UNIQUE_ID_FUT_OPT")

"""
    VendorIndexCode(value)

See [`Identifier`](@ref)
"""
VendorIndexCode = Base.Fix1(Identifier, "VENDOR_INDEX_CODE")

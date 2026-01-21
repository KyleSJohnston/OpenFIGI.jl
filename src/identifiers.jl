## https://www.openfigi.com/api/documentation#v3-id-type-values

struct Identifier
    idType::String
    idValue::String

    function Identifier(idType::String, idValue::String; validation_policy::Symbol=:error)
        validate_enum("idType", idType; validation_policy)
        new(idType, idValue)
    end
end

# TODO: document all identifiers

BarclaysTicker = Base.Fix1(Identifier, "BARCLAYS_TICKER")
BaseTicker = Base.Fix1(Identifier, "BASE_TICKER")
CompositeIDBBGlobal = Base.Fix1(Identifier, "COMPOSITE_ID_BB_GLOBAL")

"""
    IDBB(value)

A legacy Bloomberg identifier
"""
IDBB = Base.Fix1(Identifier, "ID_BB")

IDBB8Chr = Base.Fix1(Identifier, "ID_BB_8_CHR")
IDBBGlobal = Base.Fix1(Identifier, "ID_BB_GLOBAL")
IDBBGlobalShareClassLevel = Base.Fix1(Identifier, "ID_BB_GLOBAL_SHARE_CLASS_LEVEL")
IDBBSecNumDes = Base.Fix1(Identifier, "ID_BB_SEC_NUM_DES")

"""
    IDBBUnique(value)

Unique Bloomberg Identifier - A legacy, internal Bloomberg identifier

"""
IDBBUnique = Base.Fix1(Identifier, "ID_BB_UNIQUE")

"""
    CINS(value)

CINS - CUSIP International Numbering System
"""
CINS = Base.Fix1(Identifier, "ID_CINS")

"""
    Common(value)

Common Code - A nine-digit identification number
"""
Common = Base.Fix1(Identifier, "ID_COMMON")


"""
    CUSIP(value)

CUSIP - Committee on Uniform Securities Identification Procedures

"""
CUSIP = Base.Fix1(Identifier, "ID_CUSIP")

CUSIP8Chr = Base.Fix1(Identifier, "ID_CUSIP_8_CHR")
ExchangeSymbol = Base.Fix1(Identifier, "ID_EXCH_SYMBOL")
FullExchangeSymbol = Base.Fix1(Identifier, "ID_FULL_EXCHANGE_SYMBOL")

"""
    ISIN(value)

ISIN - International Securities Identification Number
"""
ISIN = Base.Fix1(Identifier, "ID_ISIN")

Italy = Base.Fix1(Identifier, "ID_ITALY")

"""
    SEDOL(value)

Sedol Number - Stock Exchange Daily Official List
"""
SEDOL = Base.Fix1(Identifier, "ID_SEDOL")

ShortCode = Base.Fix1(Identifier, "ID_SHORT_CODE")
Trace = Base.Fix1(Identifier, "ID_TRACE")

"""
    Wertpapier(value)

Wertpapierkennnummer/WKN - German securities identification code
"""
Wertpapier = Base.Fix1(Identifier, "ID_WERTPAPIER")

OCCSymbol = Base.Fix1(Identifier, "OCC_SYMBOL")
OPRASymbol = Base.Fix1(Identifier, "OPRA_SYMBOL")
Ticker = Base.Fix1(Identifier, "TICKER")
TradebookTicker = Base.Fix1(Identifier, "TRADEBOOK_TICKER")
TradingSystemIdentifier = Base.Fix1(Identifier, "TRADING_SYSTEM_IDENTIFIER")
UniqueIDFutOpt = Base.Fix1(Identifier, "UNIQUE_ID_FUT_OPT")
VendorIndexCode = Base.Fix1(Identifier, "VENDOR_INDEX_CODE")

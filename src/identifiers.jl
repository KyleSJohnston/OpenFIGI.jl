## https://www.openfigi.com/api/documentation#v3-id-type-values

"""
    Identifier(idType, idValue)

An identifier, as specified by a type an a value for that type

Typically a 3rd party construct.
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
"""
BarclaysTicker = Base.Fix1(Identifier, "BARCLAYS_TICKER")

"""
    BaseTicker(value)

An indistinct identifier which may be linked to multiple instruments. May need
to be combined with other values to identify a unique instrument.
"""
BaseTicker = Base.Fix1(Identifier, "BASE_TICKER")

"""
    CompositeIDBBGlobal(value)

Composite FIGI - The Composite FIGI enables users to link multiple FIGIs at
the trading venue level within the same country or market to obtain an
aggregated view for an instrument within that country or market.
"""
CompositeIDBBGlobal = Base.Fix1(Identifier, "COMPOSITE_ID_BB_GLOBAL")

"""
    IDBB(value)

A legacy Bloomberg identifier
"""
IDBB = Base.Fix1(Identifier, "ID_BB")

"""
    IDBB8Chr(value)
"""
IDBB8Chr = Base.Fix1(Identifier, "ID_BB_8_CHR")

"""
    IDBBGlobal(value)

FIGI - an identifier that is assigned to instruments of all asset classes and
is unique to an individual instrument. Once issued, the FIGI assigned to an
instrument will not change.
"""
IDBBGlobal = Base.Fix1(Identifier, "ID_BB_GLOBAL")

"""
    IDBBGlobalShareClassLevel(value)

Share Class FIGI - A share class level FIGI is assigned to an instrument that
is traded in more than one country. This enables users to link multiple
Composite FIGIs for the same instrument in order to obtain an aggregated view
for that instrument across all countries (globally).
"""
IDBBGlobalShareClassLevel = Base.Fix1(Identifier, "ID_BB_GLOBAL_SHARE_CLASS_LEVEL")

"""
    IDBBSecNumDes(value)

Security ID Number Description - Descriptor for a financial instrument. Similar
to the ticker fields, but will provide additional metadata data.
"""
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

"""
    CUSIP(value)

CUSIP (8 characters only) - Comittee on Uniform Securities Identification
Procedures
"""
CUSIP8Chr = Base.Fix1(Identifier, "ID_CUSIP_8_CHR")

"""
    ExchangeSymbol(value)

Common Code - a nine-digit identification number
"""
ExchangeSymbol = Base.Fix1(Identifier, "ID_EXCH_SYMBOL")

"""
    FullExchangeSymbol(value)
"""
FullExchangeSymbol = Base.Fix1(Identifier, "ID_FULL_EXCHANGE_SYMBOL")

"""
    ISIN(value)

ISIN - International Securities Identification Number
"""
ISIN = Base.Fix1(Identifier, "ID_ISIN")

"""
    Italy(value)
"""
Italy = Base.Fix1(Identifier, "ID_ITALY")

"""
    SEDOL(value)

Sedol Number - Stock Exchange Daily Official List
"""
SEDOL = Base.Fix1(Identifier, "ID_SEDOL")

"""
    ShortCode(value)

An exchange venue specific code to identify fixed income instruments primarily
traded in Asia.
"""
ShortCode = Base.Fix1(Identifier, "ID_SHORT_CODE")
Trace = Base.Fix1(Identifier, "ID_TRACE")

"""
    Wertpapier(value)

Wertpapierkennnummer/WKN - German securities identification code
"""
Wertpapier = Base.Fix1(Identifier, "ID_WERTPAPIER")

"""
    OCCSymbol(value)

OCC Symbol - A 21-character option symbol standardized by the Options Clearing
Corporation (OCC) to identify a U.S. option.
"""
OCCSymbol = Base.Fix1(Identifier, "OCC_SYMBOL")

"""
    OPRASymbol(value)

OPRA Symbol - Option symbol standardized by the Options Price Reporting
Authority (OPRA) to identify a U.S. option.
"""
OPRASymbol = Base.Fix1(Identifier, "OPRA_SYMBOL")

"""
    Ticker(value)

Ticker is a specific identifier for a financial instrument that reflects common
usage.
"""
Ticker = Base.Fix1(Identifier, "TICKER")

"""
    TradebookTicker(value)
"""
TradebookTicker = Base.Fix1(Identifier, "TRADEBOOK_TICKER")

"""
    TradingSystemIdentifier(value)

Trading System Identifier - Unique identifier for the instrument as used on the
source trading system.
"""
TradingSystemIdentifier = Base.Fix1(Identifier, "TRADING_SYSTEM_IDENTIFIER")

"""
    UniqueIDFutOpt(value)

Unique Identifier for Future Option - Bloomberg unique ticker with logic for
index, currency, single stock futures, commodities, and commodity options.
""" 
UniqueIDFutOpt = Base.Fix1(Identifier, "UNIQUE_ID_FUT_OPT")

"""
    VendorIndexCode(value)

Index code assigned by the index provider for the purpose of identifying the
security.
"""
VendorIndexCode = Base.Fix1(Identifier, "VENDOR_INDEX_CODE")

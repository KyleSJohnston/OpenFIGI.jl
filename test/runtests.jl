using Aqua
using Dates: Date
using JET
using OpenFIGI
using Test

@testset "apikey" begin
    @test isnothing(OpenFIGI.get_apikey())
    testkey = "api-key-for-testing-purposes"
    result = OpenFIGI.set_apikey(testkey)
    @test isnothing(result)
    @test OpenFIGI.get_apikey() == testkey
    OpenFIGI.set_apikey(nothing)
    @test isnothing(OpenFIGI.get_apikey())
end

@testset "Identifier tests" begin
    for constructor in (
        BarclaysTicker,
        BaseTicker,
        CompositeIDBBGlobal,
        IDBB,
        IDBB8Chr,
        IDBBGlobal,
        IDBBGlobalShareClassLevel,
        IDBBSecNumDes,
        IDBBUnique,
        CINS,
        Common,
        CUSIP,
        CUSIP8Chr,
        ExchangeSymbol,
        FullExchangeSymbol,
        ISIN,
        Italy,
        SEDOL,
        ShortCode,
        Trace,
        Wertpapier,
        OCCSymbol,
        OPRASymbol,
        Ticker,
        TradebookTicker,
        TradingSystemIdentifier,
        UniqueIDFutOpt,
        VendorIndexCode,
    )
        id = constructor("value")
        @test id isa Identifier
    end
end

@testset "Property tests" begin
    # non-Interval tests
    for constructor in (
        ExchCode,
        MICCode,
        Currency,
        MarketSecDes,
        SecurityType,
        SecurityType2,
        StateCode,
    )
        property = constructor("value"; validation_policy=:skip)
        @test property isa constructor
    end

    property = IncludeUnlistedEquities(true)
    @test property isa IncludeUnlistedEquities

    property = OptionType("Call")
    @test property isa OptionType
    property = OptionType("Put")
    @test property isa OptionType
    @test_throws ArgumentError OptionType("Other")
    @test_throws ArgumentError OptionType("Call"; validation_policy=:none)

    # Interval tests
    for constructor in (Strike, ContractSize, Coupon)
        property = constructor(75, 100)
        @test property isa Interval{Int}
        property = constructor(nothing, 100)
        @test property isa Interval{Int}
        property = constructor(75, nothing)
        @test property isa Interval{Int}

        property = constructor(75.0, 100.0)
        @test property isa Interval{Float64}
        property = constructor(nothing, 100.0)
        @test property isa Interval{Float64}
        property = constructor(75.0, nothing)
        @test property isa Interval{Float64}

        @test_throws ArgumentError constructor(nothing, nothing)
        @test_throws ArgumentError constructor(100, 75)
        @test_throws ArgumentError constructor(100.0, 75.0)
    end

    for constructor in (Expiration, Maturity)
        property = constructor(Date(2025), Date(2026))
        @test property isa Interval{Date}
        property = constructor(nothing, Date(2026))
        @test property isa Interval{Date}
        property = constructor(Date(2025), nothing)
        @test_throws ArgumentError constructor(nothing, nothing)
        @test_throws ArgumentError constructor(Date(2026), Date(2025))
        @test_throws MethodError constructor(1, 2)  # only dates allowed
    end
end

@testset "Source Code Tests" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(OpenFIGI)
    end
    if "--jettest" in ARGS
        @testset "Code linting (JET.jl)" begin
            JET.test_package(OpenFIGI; target_modules = (OpenFIGI,))
        end
    end
end

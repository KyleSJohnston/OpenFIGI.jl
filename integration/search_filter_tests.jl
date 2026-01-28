using OpenFIGI
using Test

ENV["JULIA_DEBUG"] = OpenFIGI

@testset "search" begin
    results = search_instruments("Caterpillar", MarketSecDes("Equity"), SecurityType2("Common Stock"), ExchCode("US"))
    @test results isa Vector{Instrument}
    @test length(results) == 1
    @test results[1].compositeFIGI == "BBG000BF0K17"
end

search_channel() do chnl
    @testset "paginated response search w/ channel" begin
        results_channel = Channel{Instrument}()
        search_task = search_instruments(
            chnl,
            results_channel,
            "Caterpillar",
            MarketSecDes("Equity"),
            SecurityType2("Common Stock"),
        )
        results = collect(results_channel)
        @test results isa Vector{Instrument}
        @test length(results) > 125  # 158 as of 2026-01-23
        @test !isopen(results_channel)
        @test istaskdone(search_task)
    end

    @testset "paginated response search" begin
        results = search_instruments(chnl, "Caterpillar", MarketSecDes("Equity"), SecurityType2("Common Stock"))
        @test results isa Vector{Instrument}
        @test length(results) > 125  # 158 as of 2026-01-23
        names = Set([i.name for i in results])
        @test collect(names) == ["CATERPILLAR INC"]
    end

    @testset "paginated response filter w/ channel" begin
        results_channel = Channel{Instrument}()
        filter_task = filter_instruments(
            chnl,
            results_channel,
            MarketSecDes("Equity"),
            SecurityType2("Common Stock"),
            ExchCode("NZ"),
        )
        results = collect(results_channel)
        @test results isa Vector{Instrument}
        @test length(results) > 105  # 115 as of 2026-01-27
        @test !isopen(results_channel)
        @test istaskdone(filter_task)
    end

    @testset "paginated response search" begin
        results = filter_instruments(chnl, MarketSecDes("Equity"), SecurityType2("Common Stock"), ExchCode("NZ"))
        @test results isa Vector{Instrument}
        @test length(results) > 105  # 115 as of 2026-01-27
        exch_codes = Set([i.exchCode for i in results])
        @test only(exch_codes) == "NZ"
    end
end

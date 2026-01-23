using OpenFIGI
using Test

ENV["JULIA_DEBUG"] = OpenFIGI

@testset "search" begin
    results = search("Caterpillar", MarketSecDes("Equity"), SecurityType2("Common Stock"), ExchCode("US"))
    @test results isa Vector{Instrument}
    @test length(results) == 1
    @test results[1].compositeFIGI == "BBG000BF0K17"
end

search_channel() do chnl
    @testset "paginated response search" begin
        results = search(chnl, "Caterpillar", MarketSecDes("Equity"), SecurityType2("Common Stock"))
        @test results isa Vector{Instrument}
        @test length(results) > 125  # 158 as of 2026-01-23
        names = Set([i.name for i in results])
        @test collect(names) == ["CATERPILLAR INC"]
    end
end

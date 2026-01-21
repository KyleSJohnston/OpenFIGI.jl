using Dates: Date
using OpenFIGI
using Test

ENV["JULIA_DEBUG"] = OpenFIGI


@testset "mapping/values" begin
    obj = OpenFIGI.mapping_values("idType")
    @test obj isa OpenFIGI.ValuesResponse
    @test length(obj.values) == 28
end

@testset "mapping" begin
    job = MappingJob(Ticker("AAPL"), ExchCode("US"), SecurityType2("Common Stock"))
    obj = OpenFIGI.mapping([job])
    @test length(obj) == 1
    @test obj[1] isa OpenFIGI.DataResponse
    @test length(obj[1].data) == 1
end

@testset "mapping sample request" begin
    # See https://www.openfigi.com/api/documentation#v3-post-mapping
    # Sample Request / Sample Response

    jobs = [
        MappingJob(Identifier("ID_BB_GLOBAL", "BBG000BLNNH6")),
        MappingJob(Identifier("TICKER", "IBM"), ExchCode("US")),
        MappingJob(Identifier("ID_BB_UNIQUE", "EQ0010080100001000"), Currency("USD")),
        MappingJob(Identifier("COMPOSITE_ID_BB_GLOBAL", "BBG000BLNNH6"), MICCode("XNYS"), Currency("USD")),
        MappingJob(Identifier("BASE_TICKER", "TSLA 10 C100"), SecurityType2("Option"), Expiration(Date(2018), Date(2018, 12))),
        MappingJob(Identifier("BASE_TICKER", "NFLX 9 P330"), MarketSecDes("Equity"), SecurityType2("Option"), Strike(330, nothing), Expiration(Date(2018, 7), nothing)),
        MappingJob(Identifier("BASE_TICKER", "FG"), MarketSecDes("Mtge"), SecurityType2("Pool"), Maturity(Date(2019, 9), Date(2020, 6))),
        MappingJob(Identifier("BASE_TICKER", "IBM"), MarketSecDes("Corp"), SecurityType2("Corp"), Maturity(Date(2026, 11), nothing)),
        MappingJob(Identifier("BASE_TICKER", "2251Q"), SecurityType2("Common Stock"), IncludeUnlistedEquities(true)),
    ]
    obj = OpenFIGI.mapping(jobs)
    @test obj isa Vector{<:OpenFIGI.AbstractResponse}
    @test length(obj) == length(jobs)
    println(eltype(obj))
    @test obj[1] isa OpenFIGI.DataResponse
end

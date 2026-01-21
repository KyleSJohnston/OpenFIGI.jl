using Dates: Date
using OpenFIGI
using Test

ENV["JULIA_DEBUG"] = OpenFIGI

@testset "identifiers" begin
    id = Identifier("ID_BB_GLOBAL", "BBG000000000")
    @test id isa Identifier
    @test id.idType == "ID_BB_GLOBAL"
    @test id.idValue == "BBG000000000"

    @test_throws OpenFIGI.InvalidEnumerationError Identifier("UNKNOWN", "XYZ"; validation_policy=:error)  # :error is the default
    id = @test_logs (:warn, "UNKNOWN is not an enumerated value for idType") Identifier("UNKNOWN", "XYZ"; validation_policy=:warning)
    @test id isa Identifier
    @test id.idType == "UNKNOWN"
    @test id.idValue == "XYZ"

    id = @test_nowarn Identifier("UNKNOWN", "XYZ"; validation_policy=:skip)
    @test id isa Identifier
    @test id.idType == "UNKNOWN"
    @test id.idValue == "XYZ"

    @test_throws ArgumentError Identifier("ID_BB_GLOBAL", "BBG000000000"; validation_policy=:none)
end

@testset "properties" begin
    @test_throws OpenFIGI.InvalidEnumerationError ExchCode("ZZ"; validation_policy=:error)

    id = @test_logs (:warn, "ZZ is not an enumerated value for exchCode") ExchCode("ZZ"; validation_policy=:warning)
    @test id isa ExchCode

    id = @test_nowarn ExchCode("ZZ"; validation_policy=:skip)
    @test id isa ExchCode
end

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
        MappingJob(IDBBGlobal("BBG000BLNNH6")),
        MappingJob(Ticker("IBM"), ExchCode("US")),
        MappingJob(IDBBUnique("EQ0010080100001000"), Currency("USD")),
        MappingJob(CompositeIDBBGlobal("BBG000BLNNH6"), MICCode("XNYS"), Currency("USD")),
        MappingJob(BaseTicker("TSLA 10 C100"), SecurityType2("Option"), Expiration(Date(2018), Date(2018, 12))),
        MappingJob(BaseTicker("NFLX 9 P330"), MarketSecDes("Equity"), SecurityType2("Option"), Strike(330, nothing), Expiration(Date(2018, 7), nothing)),
        MappingJob(BaseTicker("FG"), MarketSecDes("Mtge"), SecurityType2("Pool"), Maturity(Date(2019, 9), Date(2020, 6))),
        MappingJob(BaseTicker("IBM"), MarketSecDes("Corp"), SecurityType2("Corp"), Maturity(Date(2026, 11), nothing)),
        MappingJob(BaseTicker("2251Q"), SecurityType2("Common Stock"), IncludeUnlistedEquities(true)),
    ]
    obj = OpenFIGI.mapping(jobs)
    @test obj isa Vector{<:OpenFIGI.AbstractResponse}
    @test length(obj) == length(jobs)
    @test obj[1] isa OpenFIGI.DataResponse
end

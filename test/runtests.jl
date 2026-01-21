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

# TODO: unit tests for Interval

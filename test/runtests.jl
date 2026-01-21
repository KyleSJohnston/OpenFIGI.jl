using OpenFIGI
using Test

@testset "apikey" begin
    @test isnothing(OpenFIGI.get_apikey())
    testkey = "api-key-for-testing-purposes"
    OpenFIGI.set_apikey(testkey)
    @test OpenFIGI.get_apikey() == testkey
    OpenFIGI.set_apikey(nothing)
    @test isnothing(OpenFIGI.get_apikey())
end

# TODO: unit tests for Interval

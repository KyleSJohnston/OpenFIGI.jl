using Aqua
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

# TODO: unit tests for Interval

@testset "Source Code Tests" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(OpenFIGI)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(OpenFIGI; target_modules = (OpenFIGI,))
    end
end

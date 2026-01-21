using OpenFIGI
using Test

@testset "get_mapping_values" begin
    response = OpenFIGI.get_mapping_values("idType")
    obj = OpenFIGI.parse_mapping_value_response(response)
    @test obj isa OpenFIGI.ValuesResponse
    @test length(obj.values) == 28
end

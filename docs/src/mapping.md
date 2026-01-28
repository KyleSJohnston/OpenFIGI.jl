# Mapping

## Rate-Limited Methods

```@docs
instrument_mapping(::Channel{Task}, ::Vector{MappingJob})
instrument_mapping(::Channel{Task}, ::MappingJob)
instrument_mapping(::Channel{Task}, ::Identifier, ::OpenFIGI.AbstractProperty...)
instrument_mapping(::Channel{Task}, ::Channel{MappingJob}, ::Channel{<:OpenFIGI.AbstractResponse})
```

## Direct Methods

```@docs
instrument_mapping(::Vector{MappingJob})
```

## Responses

```@docs
Instrument
DataResponse
ErrorResponse
WarningResponse
```

## Enumeration Values

```@docs
OpenFIGI.mapping_values
ValuesResponse
```

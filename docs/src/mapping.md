# Mapping

## Rate-Limited Methods

```@docs
mapping(::Channel{Task}, ::Vector{MappingJob})
mapping(::Channel{Task}, ::MappingJob)
mapping(::Channel{Task}, ::Identifier, ::OpenFIGI.AbstractProperty...)
mapping(::Channel{Task}, ::Channel{MappingJob}, ::Channel{<:OpenFIGI.AbstractResponse})
```

## Direct Methods

```@docs
mapping(::Vector{MappingJob})
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

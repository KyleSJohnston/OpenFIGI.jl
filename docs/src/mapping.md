# Mapping

## Mapping Job

```@docs
MappingJob
```

## Rate-Limited Mapping

```@docs
mapping(::Channel{Task}, ::Vector{MappingJob})
mapping(::Channel{Task}, ::MappingJob)
mapping(::Channel{Task}, ::Identifier, ::OpenFIGI.AbstractProperty...)
mapping(::Channel{Task}, ::Channel{MappingJob}, ::Channel{<:OpenFIGI.AbstractResponse})
```

## Direct Mapping

```@docs
mapping(::Vector{MappingJob})
```

## Responses

```@docs
DataResponse
ErrorResponse
WarningResponse
```

## Enumeration Values

```@docs
OpenFIGI.mapping_values
```

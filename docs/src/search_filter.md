# Search & Filter

## Rate-Limited Methods

```@docs
instrument_search(::Channel{Task}, ::String, ::OpenFIGI.AbstractProperty...)
instrument_search(::Channel{Task}, ::Channel{Instrument}, ::String, ::OpenFIGI.AbstractProperty...)
instrument_filter(::Channel{Task}, properties::OpenFIGI.AbstractProperty...)
instrument_filter(::Channel{Task}, ::Channel{Instrument}, properties::OpenFIGI.AbstractProperty...)
```

## Direct Methods

```@docs
instrument_search(::String, ::OpenFIGI.AbstractProperty...)
instrument_filter(::OpenFIGI.AbstractProperty...)
```

# Getting Started

## Installation

OpenFIGI.jl can be installed using `Pkg`.

```julia
pkg> add https://github.com/KyleSJohnston/OpenFIGI.jl#v0.1.0
```

## Example Usage

```julia
using OpenFIGI

jobs = [
    MappingJob(Ticker("IBM"), ExchCode("US"), SecurityType2("Common Stock"))
    MappingJob(Ticker("AAPL"), ExchCode("US"), SecurityType2("Common Stock"))
]
results = mapping(jobs)
```

## Advanced Example

```julia
using OpenFIGI

OpenFIGI.set_apikey("YOUR-API-KEY-HERE")

# sample jobs from https://www.openfigi.com/api/documentation#v3-post-mapping

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

results = mapping_channel() do chnl
    # respect rate limits with `chnl`
    mapping(chnl, jobs)
end
```

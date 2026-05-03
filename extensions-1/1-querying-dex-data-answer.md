## Answers

### Question 1 — Introspection Query

The introspection query used to retrieve the schema (saved as `schema.json`):

```graphql
{ __schema { queryType { name } types { kind name description fields(includeDeprecated: true) { name description type { kind name ofType { kind name ofType { kind name } } } } inputFields { name type { kind name } } enumValues(includeDeprecated: true) { name } } } }
```

cURL command used to generate `schema.json`:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { queryType { name } types { kind name description fields(includeDeprecated: true) { name description type { kind name ofType { kind name ofType { kind name } } } } inputFields { name type { kind name } } enumValues(includeDeprecated: true) { name } } } }"}' \
  "https://gateway.thegraph.com/api/<API_KEY>/subgraphs/id/5zvR82QoaXYFyDEKLZ9t6v9adgnptxYpKpSbxtgVENFV" \
  -o schema.json
```

---

### Question 2 — Query 100 Pools

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{ pools(first: 100) { id token0 { id symbol } token1 { id symbol } } }"}' \
  "https://gateway.thegraph.com/api/<API_KEY>/subgraphs/id/5zvR82QoaXYFyDEKLZ9t6v9adgnptxYpKpSbxtgVENFV"
```

---

### Question 3 — 100 Pools, Highest Liquidity, Created in Past Week

The `createdAtTimestamp_gt` value is a Unix timestamp for 7 days ago (`now - 604800` seconds).

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{ pools(first: 100, orderBy: liquidity, orderDirection: desc, where: { createdAtTimestamp_gt: 1777161600 }) { id token0 { id symbol } token1 { id symbol } } }"}' \
  "https://gateway.thegraph.com/api/<API_KEY>/subgraphs/id/5zvR82QoaXYFyDEKLZ9t6v9adgnptxYpKpSbxtgVENFV"
```

---

### Question 4 — USDC/WETH Pool Full Attributes

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{ pool(id: \"0x8ad599c3a0ff1de082011efddc58f1908eb6e6d8\") { id token0 { id symbol derivedETH } token1 { id symbol derivedETH } liquidity token0Price token1Price volumeToken0 volumeToken1 volumeUSD totalValueLockedUSD } }"}' \
  "https://gateway.thegraph.com/api/<API_KEY>/subgraphs/id/5zvR82QoaXYFyDEKLZ9t6v9adgnptxYpKpSbxtgVENFV"
```

Sample response:

```json
{
  "data": {
    "pool": {
      "id": "0x8ad599c3a0ff1de082011efddc58f1908eb6e6d8",
      "token0": {
        "id": "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
        "symbol": "USDC",
        "derivedETH": "0.000433485945689491430725159335831853"
      },
      "token1": {
        "id": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
        "symbol": "WETH",
        "derivedETH": "1"
      },
      "liquidity": "1799891365784170516",
      "token0Price": "2306.879865296269527644805828148917",
      "token1Price": "0.0004334859456894914307251593358318531",
      "volumeToken0": "88787872870.934138",
      "volumeToken1": "37886829.478318872847234671",
      "volumeUSD": "88792258373.04159170502477583957804",
      "totalValueLockedUSD": "287361979.9373193645195742798767441"
    }
  }
}
```

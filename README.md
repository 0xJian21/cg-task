# CoinGecko Engineering Written Assignment — URL Shortener

A URL shortener service built with Ruby on Rails 8.1. Submit a long URL, get a short link. Every click is tracked with geolocation, timestamp, and IP — visible on a per-link stats page and a global admin report.

**Deployed URL:** https://136.113.169.29.sslip.io

---

## Installation

### Prerequisites

| Requirement | Version |
|---|---|
| Ruby | 4.0.3 |
| Rails | 8.1.3 |
| SQLite | 3.x |
| Node.js | 18+ (for Tailwind CSS compilation) |

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/0xJian21/cg-task.git
cd cg-task

# 2. Install Ruby dependencies
bundle install

# 3. Set up the database
bin/rails db:create db:migrate

# 4. Obtain GeoLite2-City.mmdb
#    Register free at https://dev.maxmind.com/geoip/geolite2-free-geolocation-data
#    Download GeoLite2-City.mmdb and place it at the project root:
cp /path/to/GeoLite2-City.mmdb .
#    Or set a custom path via environment variable:
#    export GEOIP_DB_PATH=/path/to/GeoLite2-City.mmdb

# 5. Start the development server
bin/dev
```

The app will be available at `http://localhost:3000`.

### Running tests

```bash
bin/rails test
```

### Linting

```bash
bin/rubocop --autocorrect
```

---

## Dependencies

| Gem | Purpose |
|---|---|
| `rails 8.1.3` | Web framework |
| `sqlite3` | Database adapter |
| `puma` | Web server |
| `turbo-rails` | Hotwire Turbo — SPA-like navigation without a JS framework |
| `stimulus-rails` | Hotwire Stimulus — lightweight JS controllers (copy button) |
| `tailwindcss-rails` | Utility-first CSS, compiled at build time |
| `nokogiri` | HTML parsing for `<title>` tag extraction |
| `maxminddb` | MaxMind GeoLite2 `.mmdb` local IP geolocation lookups |
| `rack-attack` | Rate limiting middleware — throttles `POST /links` per IP |
| `propshaft` | Asset pipeline |

**Scaffolding tools used:**
- `rails new` with default Hotwire stack
- `bin/rails generate migration` for schema changes
- `tailwindcss-rails` install generator
- Dokku for production deployment

---

## Architecture

### Data model

```
short_urls
  slug        string  unique, ≤ 15 chars, Base62
  target_url  string  http/https only
  title       string  fetched at creation time
  created_at

visits
  short_url_id  FK → short_urls
  ip_address    string
  country       string  (nullable — GeoIP failure stored as null)
  city          string  (nullable)
  clicked_at    datetime
```

### Service objects

**`TitleFetcherService`** — fetches the `<title>` of the target URL using `Net::HTTP`. Follows up to 5 redirects, enforces 5s timeouts, reads at most 100 KB, and blocks requests to loopback/RFC1918/link-local addresses (SSRF mitigation). Returns `"(title unavailable)"` on any failure.

**`GeolocateService`** — wraps a MaxMind GeoLite2 local `.mmdb` lookup. Returns `{ country:, city: }`. Catches all exceptions internally — a missing database never breaks the redirect path.

### Routing

```ruby
root "links#new"                            # landing page
resources :links, only: %i[new create show] # /links/new, POST /links, /links/:slug
get "/reports" => "reports#index"           # admin report
get "/:slug"   => "redirect#show"           # catch-all — declared last to avoid shadowing
```

The `/:slug` wildcard is intentionally the last route so it cannot shadow `/links`, `/reports`, or `/up`.

---

## Short URL Algorithm

Slugs are generated using `SecureRandom.alphanumeric` from the Base62 character set `[A-Za-z0-9]`, defaulting to 6 characters (hard cap 15).

**Uniqueness:** checked before save. On collision, generation retries up to 5 times, then raises a user-visible `SlugExhaustedError`. This avoids silent failures or infinite loops.

**Space:** 62^6 ≈ 57 billion combinations — negligible collision rate at small scale.

**Redirect code:** 302 (not 301). A 301 is cached permanently by browsers — subsequent clicks would bypass the server, breaking visit tracking.

**Limitations:**
- Collision probability grows at very large scale (tens of millions of slugs)
- Slugs are case-sensitive (`aB3k` ≠ `ab3k`)
- Users cannot choose memorable custom paths

**Workarounds:**
- Increase default length to 8 chars for larger deployments (62^8 ≈ 218 trillion)
- Allow optional custom slugs with a reserved-word blocklist (`/links`, `/reports`, `/up`, `/health`)

---

## Security

| Concern | Mitigation |
|---|---|
| SSRF via title fetch | `TitleFetcherService` resolves hostname to IP before connecting; blocks loopback, RFC1918, and link-local ranges |
| URL scheme injection | `ShortUrl` validates `target_url` scheme against allowlist (`http`, `https`); rejects `javascript:`, `data:`, `file:` etc. |
| Open redirect | `RedirectController` only redirects to the stored `target_url` — never to a query parameter |
| XSS | Standard ERB escaping throughout; `html_safe` never called on user-controlled data |
| CSRF | Rails default `protect_from_forgery` — not disabled |
| Slug spam / DoS | `rack-attack` throttles `POST /links` to 10 requests/minute per IP |
| Transport security | TLS via Let's Encrypt (auto-renewing); HSTS enabled (max-age ~6 months) |

---

## Scalability

**Current constraints (SQLite, single process):**
- SQLite handles ~100k slugs and moderate concurrent reads without issue; write concurrency is limited by SQLite's single-writer model
- Puma is configured with 3 threads; RAM on the e2-micro (~1 GB) is the practical concurrency ceiling
- Title fetching is synchronous at creation time — slow upstream pages block the create request for up to 5s

**Path to scale:**
- Swap SQLite for Postgres to unlock concurrent writes and connection pooling
- Move title fetching to a background job (Solid Queue is already in the Gemfile) to make creation instant
- Add a database index on `visits.clicked_at` if time-range queries are introduced
- Slug space scales by increasing default length (6 → 8 chars = 218 trillion combinations)

---

## Deployment

Deployed on **GCP Compute Engine e2-micro** (free tier, `us-central1-a`) using **Dokku** as the PaaS layer.

- Dokku builds the Docker image on the VM from the `Dockerfile` on every `git push dokku main`
- SQLite database persisted at `/var/lib/dokku/data/storage/url-shortener`, bind-mounted into the container at `/rails/storage`
- `db:migrate` runs automatically via the `release` phase in `Procfile`
- TLS certificate issued by Let's Encrypt via `dokku-letsencrypt`; auto-renewed via cron
- Secrets set via `dokku config:set` (never committed to git)

---

## Extension 1: Querying Data from Decentralized Exchanges

The full question brief and answers live in [`extensions-1/`](extensions-1/).

| File | Description |
|---|---|
| `1-querying-dex-data.md` | Original question brief |
| `1-querying-dex-data-answer.md` | cURL queries and sample responses for all four questions |
| `schema.json` | UniswapV3 GraphQL schema retrieved via introspection query |

### Summary of answers

**Q1 — Schema introspection**
GraphQL introspection query sent to the UniswapV3 subgraph endpoint; result saved as `schema.json`.

**Q2 — 100 pools (basic)**
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{ pools(first: 100) { id token0 { id symbol } token1 { id symbol } } }"}' \
  "https://gateway.thegraph.com/api/<API_KEY>/subgraphs/id/5zvR82QoaXYFyDEKLZ9t6v9adgnptxYpKpSbxtgVENFV"
```

**Q3 — 100 pools, highest liquidity, created in past week**
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{ pools(first: 100, orderBy: liquidity, orderDirection: desc, where: { createdAtTimestamp_gt: 1777161600 }) { id token0 { id symbol } token1 { id symbol } } }"}' \
  "https://gateway.thegraph.com/api/<API_KEY>/subgraphs/id/5zvR82QoaXYFyDEKLZ9t6v9adgnptxYpKpSbxtgVENFV"
```

**Q4 — USDC/WETH pool full attributes**
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{ pool(id: \"0x8ad599c3a0ff1de082011efddc58f1908eb6e6d8\") { id token0 { id symbol derivedETH } token1 { id symbol derivedETH } liquidity token0Price token1Price volumeToken0 volumeToken1 volumeUSD totalValueLockedUSD } }"}' \
  "https://gateway.thegraph.com/api/<API_KEY>/subgraphs/id/5zvR82QoaXYFyDEKLZ9t6v9adgnptxYpKpSbxtgVENFV"
```

---

## Test Coverage

55 tests, 0 failures across:

- **Model unit tests** — `ShortUrl` validations, slug generation (charset, length, uniqueness retry, exhaustion error), `to_param` override
- **Service unit tests** — `TitleFetcherService` (happy path, timeout, non-HTML, SSRF block, oversized response) and `GeolocateService` (happy path, lookup failure) — all HTTP calls stubbed, no real network in CI
- **Request/integration tests** — full HTTP stack via `ActionDispatch::IntegrationTest`: create flow, redirect + visit recording, 404 on unknown slug, stats page, global report, rate limiting

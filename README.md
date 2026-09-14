> **This is a public read-only mirror.** The source of truth lives in `packages/sdk-ios` of
> TBBN's private main repository; this mirror exists solely so Swift Package Manager (which
> resolves dependencies directly from a git URL, not a decoupled artifact registry) can fetch it
> without needing access to the private repo. Content here is kept in sync automatically — don't
> open PRs directly against this repo.

# sdk-ios (`TBBNSDK` Swift Package)

**Status: WORKING (source only) — untested.** This folder is a plain Swift Package, not an npm
package — it was never `@tbbn/sdk-ios`; that naming only applies to the real npm packages under
`packages/sdk-*` (sdk-js, sdk-typescript, sdk-react, sdk-next, sdk-vue, sdk-rn). No Swift
toolchain exists in the environment this was written in, so this code has not been compiled or
run — see `.github/workflows/sdk-ios-ci.yml` for the build-verification run once this is pushed
(needs a macOS runner). Written as a faithful translation of `packages/sdk-js/src/client.ts`'s
full method surface (all 27 resource groups, Phase 0-13). Review before shipping to production.

Real Swift Package Manager layout (`Package.swift`, `Sources/TBBNSDK/*.swift`). `TbbnClient` is
an `actor` (not a class) — safe to call concurrently from multiple tasks without callers needing
their own locking, using `URLSession` + Swift concurrency (`async`/`await`), iOS 15+/macOS 12+.
Depends on `swift-crypto` for webhook signature verification only.

```swift
import TBBNSDK

let client = TbbnClient(baseUrl: "https://sandbox-api.tbbnetwork.com", apiKey: "sk_sandbox_...")

let offer = try await client.offers.create([
    "fromSellerId": "...",
    "toSellerId": "...",
    "listingIdsA": ["..."],
    "listingIdsB": ["..."],
])
```

Not yet published; add as a Swift Package dependency pointing at this folder (local path or a
git remote) until it is.

## Webhook signature verification

```swift
let isValid = verifyWebhookSignature(rawBody: body, signatureHeader: header, signingSecret: secret)
```

## Coverage

`auth`, `merchants`, `apiKeys`, `sellers`, `listings`, `catalog`, `media`, `directory`,
`search`, `tradeEngine`, `currency`, `localization`, `matching`, `recommendations`, `offers`,
`reservations`, `tradeSessions`, `checkout`, `billing`, `notifications`, `webhooks`,
`auditLogs`, `moderation`, `fraud`, `reputation`, `analytics`, `features`, `sandbox` — every
resource group `sdk-js` exposes. Response types use `AnyDecodable` (a loose JSON box) rather
than fixed `Codable` models for every endpoint — defining a full model per response shape across
27 resource groups is future work once real usage informs which ones are worth the strict typing.

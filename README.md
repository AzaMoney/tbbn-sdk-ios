> **This is a public read-only mirror.** The source of truth lives in `packages/sdk-ios` of
> TBBN's private main repository; this mirror exists solely so Swift Package Manager (which
> resolves dependencies directly from a git URL, not a decoupled artifact registry) can fetch it
> without needing access to the private repo. Content here is kept in sync automatically — don't
> open PRs directly against this repo.

# sdk-ios (`TBBNSDK` Swift Package)

**Status: WORKING — build-verified via CI.** This folder is a plain Swift Package, not an npm
package — it was never `@tbbn/sdk-ios`; that naming only applies to the real npm packages under
`packages/sdk-*` (sdk-js, sdk-typescript, sdk-react, sdk-next, sdk-vue, sdk-rn). No Swift
toolchain exists in this dev environment, so `.github/workflows/sdk-ios-ci.yml` (a macOS runner)
is the only place this has ever actually been compiled. Written as a faithful translation of
`packages/sdk-js/src/client.ts`'s full method surface (all 27 resource groups, Phase 0-13).

Real Swift Package Manager layout (`Package.swift`, `Sources/TBBNSDK/*.swift`). `TbbnClient` is
an `actor` (not a class) — safe to call concurrently from multiple tasks without callers needing
their own locking, using `URLSession` + Swift concurrency (`async`/`await`), iOS 15+/macOS 12+.
Depends on `swift-crypto` for webhook signature verification only.

```swift
import TBBNSDK

let client = TbbnClient(baseUrl: "https://api.tbbnetwork.com", apiKey: "sk_sandbox_...")

let offer = try await client.offers.create([
    "fromSellerId": "...",
    "toSellerId": "...",
    "listingIdsA": ["..."],
    "listingIdsB": ["..."],
])
```

## Installing

```swift
.package(url: "https://github.com/AzaMoney/tbbn-sdk-ios", from: "0.1.0")
```

Or in Xcode: **File → Add Package Dependencies…** and paste
`https://github.com/AzaMoney/tbbn-sdk-ios`.

Swift Package Manager resolves dependencies directly from a git URL — there's no artifact
registry to upload to the way npm/Maven Central/PyPI work. Since TBBN's main repository is
private, `AzaMoney/tbbn-sdk-ios` is a small **public** mirror containing only this folder's
source, kept in sync automatically by `.github/workflows/mirror-sdk-ios.yml` whenever this
folder changes on `master`. Cutting a new consumer-facing version is a separate, manual step
(tag the mirror repo directly) — the mirror's main branch always reflects the latest source, but
existing tags never move.

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

## Publishing a new version

Push any change here (auto-syncs to the public mirror), then tag the **mirror** repo directly (`AzaMoney/tbbn-sdk-ios`, not this one) with the new version and push that tag — no separate submission step, SPM resolves any tag immediately. See `docs/architecture/sdk-publishing.md` for the complete runbook.

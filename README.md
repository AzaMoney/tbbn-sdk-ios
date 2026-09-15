> **This is a public read-only mirror.** The source of truth lives in `packages/sdk-ios` of
> TBBN's private main repository; this mirror exists solely so Swift Package Manager (which
> resolves dependencies directly from a git URL, not a decoupled artifact registry) can fetch it
> without needing access to the private repo. Content here is kept in sync automatically — don't
> open PRs directly against this repo.

# TBBNSDK

Swift client for the [TBBN Platform API](https://developer.tbbnetwork.com). Publish listings, manage offers and trade
sessions, and verify webhooks. iOS 15+ / macOS 12+, `async`/`await` throughout. `TbbnClient`
is an actor, so it is safe to share across tasks.

## Install

In Xcode: **File → Add Package Dependencies…** and paste
`https://github.com/AzaMoney/tbbn-sdk-ios`. Or in `Package.swift`:

```swift
.package(url: "https://github.com/AzaMoney/tbbn-sdk-ios", from: "0.1.0")
```

## Quick start

```swift
import TBBNSDK

let client = TbbnClient(baseUrl: "https://api.tbbnetwork.com", apiKey: "sk_sandbox_...")

let listing = try await client.listings.upsert([
    "merchantId": "...",
    "merchantListingRef": "sku-1042",
    "sellerId": "...",
    "listingType": "BOTH",
    "title": "Nike Air Max 90 — size 10, lightly worn",
    "category": "Apparel",
    "originalPrice": 150,
    "requestedAmount": 25,
    "currency": "USD",
    "visibility": "GLOBAL",
])

let offers = try await client.offers.list(sellerId: "...", direction: "received")
```

Responses are `AnyDecodable` — a loosely typed JSON box with a `.value` you can cast. A
complete runnable walkthrough is in [`example/Basic.swift`](./example/Basic.swift).

## Authentication

Pass either an **API key** (`apiKey`, issued to your merchant at
[merchants.tbbnetwork.com](https://merchants.tbbnetwork.com)) or a **session token**
(`accessToken`, obtained through one of the `auth` sign-in flows). Sandbox keys
(`sk_sandbox_…`) work against the same API and never touch live data.

## Webhooks

Verify every inbound delivery before trusting it. Pass the raw request body exactly as
received — re-serialising the JSON changes the bytes and the signature will not match.
Signatures are HMAC-SHA256 with a five-minute replay window.

```swift
let ok = verifyWebhookSignature(rawBody: body, signatureHeader: header, signingSecret: secret)
```

## Errors

Every non-2xx response throws `TbbnApiError` with `status`, `code`, `message`, and `requestId`. Quote the request id when asking
for help with a specific call.

## Resources

`auth`, `merchants`, `apiKeys`, `sellers`, `listings`, `catalog`, `media`, `directory`, `search`, `tradeEngine`, `currency`, `localization`, `matching`, `recommendations`, `offers`, `tradeSessions`, `checkout`, `billing`, `notifications`, `webhooks`, `auditLogs`, `moderation`, `fraud`, `reputation`, `analytics`, `features`, `sandbox`. Each method maps one-to-one onto an API endpoint documented in the
[API reference](https://developer.tbbnetwork.com/merchant/docs/api).

## Support

Questions and bug reports: the [developer community](https://developer.tbbnetwork.com/community).

## License

MIT © Trade By Barter Network, Inc.

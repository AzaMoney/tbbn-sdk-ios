// A minimal end-to-end walkthrough: publish a listing, look at incoming offers, and verify a
// webhook delivery. Run against the sandbox with a sandbox key. TbbnClient is an actor, so every
// call is `async throws` — call it from a Task or any async context.
//
//   TBBN_API_KEY=sk_sandbox_... TBBN_MERCHANT_ID=... TBBN_SELLER_ID=... swift run
import Foundation
import TBBNSDK

@main
struct Basic {
    static func main() async {
        let env = ProcessInfo.processInfo.environment
        let client = TbbnClient(
            baseUrl: env["TBBN_API_BASE_URL"] ?? "https://api.tbbnetwork.com",
            apiKey: env["TBBN_API_KEY"]
        )

        do {
            // 1. Publish (or update) one of your seller's items. merchantListingRef is your own id
            //    for the item, so calling this again with the same ref updates rather than duplicates.
            let listing = try await client.listings.upsert([
                "merchantId": env["TBBN_MERCHANT_ID"],
                "merchantListingRef": "sku-1042",
                "sellerId": env["TBBN_SELLER_ID"],
                "listingType": "BOTH",
                "title": "Nike Air Max 90 — size 10, lightly worn",
                "category": "Apparel",
                "subcategory": "Sneakers",
                "brand": "Nike",
                "condition": "Good",
                "originalPrice": 150,
                "requestedAmount": 25,
                "currency": "USD",
                "visibility": "GLOBAL",
                "wants": [["category": "Electronics", "subcategory": "Tablets"]],
            ])?.value as? [String: Any] ?? [:]
            print("Listing \(listing["id"] ?? "?") is live.")

            // 2. See what other sellers have offered for it.
            let offers = try await client.offers.list(sellerId: listing["sellerId"] as? String ?? "", direction: "received")?
                .value as? [Any] ?? []
            print("\(offers.count) offer(s) waiting.")

            // 3. When a webhook arrives, verify it before trusting the payload. In a real handler,
            //    pass the raw request body and the X-TBBN-Signature header.
            let ok = verifyWebhookSignature(
                rawBody: #"{"type":"offer.created","data":{}}"#,
                signatureHeader: "t=1700000000,v1=deadbeef",
                signingSecret: "whsec_example",
                now: 1_700_000_000
            )
            print("Webhook signature valid: \(ok)")
        } catch let error as TbbnApiError {
            FileHandle.standardError.write(Data("API error \(error.status) \(error.code): \(error.message) (request \(error.requestId ?? "-"))\n".utf8))
        } catch {
            FileHandle.standardError.write(Data("\(error)\n".utf8))
        }
    }
}

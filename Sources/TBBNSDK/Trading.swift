import Foundation

public final class TradeEngineResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func computeSettlement(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/trade-engine/settlement", body: input)
    }
}

public final class CurrencyResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func supported() async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/currency/supported")
    }

    public func convert(amount: Double, from: String, to: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/currency/convert", body: ["amount": amount, "from": from, "to": to])
    }
}

public final class LocalizationResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func countries() async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/localization/countries")
    }

    public func languages() async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/localization/languages")
    }

    public func normalizePhone(phone: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/localization/normalize-phone", body: ["phone": phone])
    }
}

public final class MatchingResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func candidates(listingId: String, limit: Int? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/matching/candidates", body: ["listingId": listingId, "limit": limit])
    }

    public func score(listingIdA: String, listingIdB: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/matching/score", body: ["listingIdA": listingIdA, "listingIdB": listingIdB])
    }
}

public final class RecommendationsResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func forSeller(sellerId: String, limit: Int? = nil) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/recommendations/sellers/\(sellerId)", ["limit": limit]))
    }
}

public final class OffersResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func create(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/offers", body: input)
    }

    public func list(sellerId: String, direction: String = "all") async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/offers", ["sellerId": sellerId, "direction": direction]))
    }

    public func get(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/offers/\(id)")
    }

    public func accept(id: String, actingSellerId: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/offers/\(id)/accept", body: ["actingSellerId": actingSellerId])
    }

    public func reject(id: String, actingSellerId: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/offers/\(id)/reject", body: ["actingSellerId": actingSellerId])
    }

    public func cancel(id: String, actingSellerId: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/offers/\(id)/cancel", body: ["actingSellerId": actingSellerId])
    }

    public func counter(id: String, input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/offers/\(id)/counter", body: input)
    }
}

public final class TradeSessionsResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func list(sellerId: String) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/trade-sessions", ["sellerId": sellerId]))
    }

    public func get(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/trade-sessions/\(id)")
    }

    public func cancel(id: String, actingSellerId: String, reason: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/trade-sessions/\(id)/cancel", body: ["actingSellerId": actingSellerId, "reason": reason])
    }

    /// The paid side closes a trade the other side never completed, once the hold has elapsed.
    public func closeUnreciprocated(id: String, actingSellerId: String, note: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/trade-sessions/\(id)/close-unreciprocated", body: ["actingSellerId": actingSellerId, "note": note])
    }

    /// Peer-to-peer completion: either party confirms the exchange happened.
    public func confirmScheduling(id: String, actingSellerId: String, confirmedByMerchantUserId: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/trade-sessions/\(id)/scheduling/confirm", body: ["actingSellerId": actingSellerId, "confirmedByMerchantUserId": confirmedByMerchantUserId])
    }

    public func failScheduling(id: String, actingSellerId: String, reason: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/trade-sessions/\(id)/scheduling/fail", body: ["actingSellerId": actingSellerId, "reason": reason])
    }

    /// Excuses the paid side from fulfilling once the counterparty hold has elapsed.
    public func excuseFulfillment(id: String, note: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/trade-sessions/\(id)/excuse-fulfillment", body: ["note": note])
    }

    public func acknowledgeHoldTerms(id: String, actingSellerId: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/trade-sessions/\(id)/acknowledge-hold-terms", body: ["actingSellerId": actingSellerId])
    }

    /// Suggests a TBBN Space location for the exchange; the other side accepts it.
    public func proposeSpace(id: String, branchId: String, actingSellerId: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/trade-sessions/\(id)/space-proposals", body: ["branchId": branchId, "actingSellerId": actingSellerId])
    }

    public func listSpaceProposals(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/trade-sessions/\(id)/space-proposals")
    }

    public func acceptSpaceProposal(id: String, proposalId: String, actingSellerId: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/trade-sessions/\(id)/space-proposals/\(proposalId)/accept", body: ["actingSellerId": actingSellerId])
    }
}

public final class CheckoutResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func paymentWebhook(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/checkout/webhooks/payment", body: input)
    }

    public func fulfillmentWebhook(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/checkout/webhooks/fulfillment", body: input)
    }

    public func complete(tradeSessionId: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/checkout/trade-sessions/\(tradeSessionId)/complete")
    }

    public func payments(tradeSessionId: String) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/checkout/payments", ["tradeSessionId": tradeSessionId]))
    }
}

import Foundation

public final class BillingResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func createSubscription(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/billing/subscriptions", body: input)
    }

    public func getSubscription(merchantId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/billing/subscriptions/\(merchantId)")
    }

    public func changeTier(merchantId: String, tier: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/billing/subscriptions/\(merchantId)/change-tier", body: ["tier": tier])
    }

    public func cancelSubscription(merchantId: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/billing/subscriptions/\(merchantId)/cancel")
    }

    public func recordUsage(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/billing/usage", body: input)
    }

    public func usageSummary(merchantId: String, billingPeriodRef: String? = nil) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/billing/usage/\(merchantId)", ["billingPeriodRef": billingPeriodRef]))
    }
}

public final class NotificationsResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func list(userId: String) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/notifications", ["userId": userId]))
    }

    public func markRead(id: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/notifications/\(id)/read")
    }
}

public final class WebhooksResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func createSubscription(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/webhooks/subscriptions", body: input)
    }

    public func listSubscriptions(merchantId: String) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/webhooks/subscriptions", ["merchantId": merchantId]))
    }

    public func disableSubscription(id: String, merchantId: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/webhooks/subscriptions/\(id)/disable", body: ["merchantId": merchantId])
    }

    public func listDeliveries(subscriptionId: String? = nil) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/webhooks/deliveries", ["subscriptionId": subscriptionId]))
    }

    public func replayDelivery(id: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/webhooks/deliveries/\(id)/replay")
    }
}

public final class AuditLogsResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func list(query: [String: Any?] = [:]) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/audit-logs", query))
    }
}

public final class ModerationResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func listFlags(query: [String: Any?] = [:]) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/moderation/flags", query))
    }

    public func getFlag(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/moderation/flags/\(id)")
    }

    public func reviewFlag(id: String, reviewedBy: String, decision: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/moderation/flags/\(id)/review", body: ["reviewedBy": reviewedBy, "decision": decision])
    }
}

public final class FraudResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func listSignals(query: [String: Any?] = [:]) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/fraud/signals", query))
    }
}

public final class ReputationResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func getScore(sellerId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/reputation/sellers/\(sellerId)")
    }
}

public final class AnalyticsResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func overview(query: [String: Any?] = [:]) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/analytics/overview", query))
    }
}

public final class FeaturesResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func upsert(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/features", body: input)
    }

    public func list(merchantId: String? = nil) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/features", ["merchantId": merchantId]))
    }

    public func check(key: String, merchantId: String? = nil) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/features/\(key)/check", ["merchantId": merchantId]))
    }
}

public final class SandboxResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func provisionMerchant(displayName: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/sandbox/merchants", body: ["displayName": displayName])
    }

    public func fixtures() async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/sandbox/fixtures")
    }
}

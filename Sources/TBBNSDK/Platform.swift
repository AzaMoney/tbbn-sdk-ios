import Foundation

/// TBBN's own plan and usage billing, per Business — never trade money. Every method takes a
/// Business id.
public final class BillingResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    /// Starts a plan (`businessId`, `billingEmail`, `tier`, optional `interval` MONTH/YEAR). A paid
    /// plan returns a Stripe Checkout `checkoutUrl`.
    public func createSubscription(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/billing/subscriptions", body: input)
    }

    public func getSubscription(businessId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/billing/subscriptions/\(businessId)")
    }

    /// Whether service is paused (unpaid invoice or a usage balance below zero).
    public func suspension(businessId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/billing/subscriptions/\(businessId)/suspension")
    }

    /// Upgrade (charged now) or downgrade (at period end); `interval` is MONTH or YEAR.
    public func changePlan(businessId: String, tier: String, interval: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/billing/subscriptions/\(businessId)/change-plan", body: ["tier": tier, "interval": interval])
    }

    public func changeTier(businessId: String, tier: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/billing/subscriptions/\(businessId)/change-tier", body: ["tier": tier])
    }

    public func cancelSubscription(businessId: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/billing/subscriptions/\(businessId)/cancel")
    }

    /// Applies a finished Stripe Checkout (plan, top-up or card). Safe to call twice.
    public func completeCheckout(sessionId: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/billing/checkout/complete", body: ["sessionId": sessionId])
    }

    /// The usage balance, alarms, and this allowance window's usage per service.
    public func wallet(businessId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/billing/wallet/\(businessId)")
    }

    /// Adds to the usage balance (stays on the same plan). Returns a Checkout URL.
    public func topUp(businessId: String, amountUsd: Double) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/billing/wallet/\(businessId)/top-up", body: ["amountUsd": amountUsd])
    }

    public func recordUsage(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/billing/usage", body: input)
    }

    public func usageSummary(businessId: String, billingPeriodRef: String? = nil) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/billing/usage/\(businessId)", ["billingPeriodRef": billingPeriodRef]))
    }

    /// Where usage went — `groupBy` is day, merchant or eventType.
    public func usageBreakdown(businessId: String, from: String? = nil, to: String? = nil, groupBy: String? = nil) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/billing/usage/\(businessId)/breakdown", ["from": from, "to": to, "groupBy": groupBy]))
    }

    public func statement(businessId: String, billingPeriodRef: String? = nil) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/billing/statements/\(businessId)", ["billingPeriodRef": billingPeriodRef]))
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

    /// Ownership comes from your credential.
    public func disableSubscription(id: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/webhooks/subscriptions/\(id)/disable")
    }

    public func listDeliveries(subscriptionId: String) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/webhooks/deliveries", ["subscriptionId": subscriptionId]))
    }

    public func replayDelivery(id: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/webhooks/deliveries/\(id)/replay")
    }

    /// Business (TBBN Space) webhooks — booking lifecycle events. ADMIN or DEVELOPER role.
    public func createBusinessSubscription(businessId: String, url: String, events: [String]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/webhooks/business-subscriptions", body: ["businessId": businessId, "url": url, "events": events])
    }

    public func listBusinessSubscriptions(businessId: String) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/webhooks/business-subscriptions", ["businessId": businessId]))
    }

    public func disableBusinessSubscription(id: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/webhooks/business-subscriptions/\(id)/disable")
    }

    public func listBusinessDeliveries(subscriptionId: String) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/webhooks/business-deliveries", ["subscriptionId": subscriptionId]))
    }

    public func replayBusinessDelivery(id: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/webhooks/business-deliveries/\(id)/replay")
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

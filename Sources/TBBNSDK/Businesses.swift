import Foundation

/// Businesses — the account that owns locations (Branches), linked Merchants, billing and TBBN
/// Space hosting.
public final class BusinessesResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    /// `type` is INDIVIDUAL or REGISTERED (REGISTERED also needs `legalName`); only a verified
    /// REGISTERED Business can run a Merchant.
    public func create(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/businesses", body: input)
    }

    public func get(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/businesses/\(id)")
    }

    /// Businesses you own.
    public func list() async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/businesses")
    }

    /// `stepUpToken` is required once the Business is verified.
    public func update(id: String, patch: [String: Any?], stepUpToken: String? = nil) async throws -> AnyDecodable? {
        try await client.request("PATCH", "/v1/businesses/\(id)", body: patch, extraHeaders: stepUpToken.map { ["x-tbbn-step-up-token": $0] } ?? [:])
    }

    public func listUsers(businessId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/businesses/\(businessId)/business-users")
    }

    /// The team's invitations waiting for an answer.
    public func listInvitations(businessId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/businesses/\(businessId)/invitations")
    }
}

/// A Business's locations.
public final class BranchesResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func create(businessId: String, _ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/businesses/\(businessId)/branches", body: input)
    }

    public func list(businessId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/businesses/\(businessId)/branches")
    }

    public func update(id: String, patch: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("PATCH", "/v1/branches/\(id)", body: patch)
    }

    public func delete(id: String) async throws -> AnyDecodable? {
        try await client.request("DELETE", "/v1/branches/\(id)")
    }

    /// `spaceStatus` is NOT_ENABLED or SPACE_ENABLED.
    public func setSpaceStatus(id: String, spaceStatus: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/branches/\(id)/space-status", body: ["spaceStatus": spaceStatus])
    }

    /// Creates or updates many locations at once, keyed by each one's `externalLocationId`.
    public func bulkUpsert(businessId: String, locations: [[String: Any]]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/businesses/\(businessId)/branches/bulk", body: ["locations": locations])
    }
}

/// Links between a Business and the Merchants it runs.
public final class BusinessMerchantLinksResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func create(businessId: String, merchantId: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/businesses/\(businessId)/merchant-links", body: ["merchantId": merchantId])
    }

    public func listForBusiness(businessId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/businesses/\(businessId)/merchant-links")
    }

    public func revoke(businessId: String, linkId: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/businesses/\(businessId)/merchant-links/\(linkId)/revoke")
    }
}

/// TBBN Space — search, booking terms and bookings. Construct the client with a Space API key
/// (`sk_space_...`) to book for clients without a TBBN account.
public final class SpaceResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    /// Query keys include country, region, category, lat/lng, radiusMiles, query, minCapacity,
    /// amenity, sortBy and limit.
    public func search(_ query: [String: Any?] = [:]) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/space/search", query))
    }

    public func listSpaces(branchId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/space/branches/\(branchId)/spaces")
    }

    public func getSpace(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/space/spaces/\(id)")
    }

    /// The refund and no-show policy, processing fee and terms a guest agrees to.
    public func bookingTerms(spaceId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/space/spaces/\(spaceId)/booking-terms")
    }

    /// A member booking must include `acceptTerms: true`.
    public func createBooking(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/space/bookings", body: input)
    }

    public func listBookings(_ query: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/space/bookings", query))
    }

    public func paymentInfo(bookingId: String, token: String? = nil) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/space/bookings/\(bookingId)/payment-info", ["token": token]))
    }

    public func cancelBooking(bookingId: String, token: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", withQuery("/v1/space/bookings/\(bookingId)/cancel", ["token": token]))
    }

    public func rescheduleBooking(bookingId: String, scheduledAt: String, token: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", withQuery("/v1/space/bookings/\(bookingId)/reschedule", ["token": token]), body: ["scheduledAt": scheduledAt])
    }

    /// The host cancels; the guest is refunded in full.
    public func hostCancelBooking(bookingId: String, reason: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/space/bookings/\(bookingId)/host-cancel", body: ["reason": reason])
    }
}

/// A scheduled catalog feed from your own feed URL.
public final class MerchantFeedResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func get() async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/merchant/feed-source")
    }

    public func set(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/merchant/feed-source", body: input)
    }

    public func fetchNow() async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/merchant/feed-source/fetch-now")
    }
}

/// Your merchant's OAuth clients for seller account linking.
public final class OAuthClientsResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func create(merchantId: String, redirectUris: [String], idempotencyKey: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/oauth-clients", body: ["merchantId": merchantId, "redirectUris": redirectUris], extraHeaders: idempotencyHeader(idempotencyKey))
    }

    public func list(merchantId: String) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/oauth-clients", ["merchantId": merchantId]))
    }

    public func rotateSecret(id: String, idempotencyKey: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/oauth-clients/\(id)/rotate-secret", extraHeaders: idempotencyHeader(idempotencyKey))
    }

    public func revoke(id: String) async throws -> AnyDecodable? {
        try await client.request("DELETE", "/v1/oauth-clients/\(id)")
    }
}

/// Seller account linking (OAuth 2.0). Call `token` from your backend only.
public final class OAuthLinkResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func getClient(clientId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/link/oauth/clients/\(clientId)")
    }

    public func token(code: String, clientId: String, clientSecret: String, redirectUri: String, codeVerifier: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/link/oauth/token", body: [
            "grant_type": "authorization_code",
            "code": code,
            "client_id": clientId,
            "client_secret": clientSecret,
            "redirect_uri": redirectUri,
            "code_verifier": codeVerifier,
        ])
    }
}

/// 1–5 star reviews, earned by a completed trade or Space booking.
public final class ReviewsResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func create(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/reputation/reviews", body: input)
    }

    public func forMerchant(merchantId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/reputation/merchants/\(merchantId)/reviews")
    }

    public func forBranch(branchId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/reputation/branches/\(branchId)/reviews")
    }
}

/// Live platform status.
public final class StatusResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    /// Public, no credential needed.
    public func get() async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/status")
    }
}

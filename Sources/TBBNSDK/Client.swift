// Status: WORKING (source only) — untested. See Package.swift header for details.

import Foundation

/// Thrown for any non-2xx API response. Mirrors the shared
/// `{ "error": { "code", "message", "requestId" } }` envelope documented in openapi.yaml's Error
/// schema.
public struct TbbnApiError: Error, CustomStringConvertible {
    public let status: Int
    public let code: String
    public let message: String
    public let requestId: String?

    public var description: String { "TbbnApiError(\(status), \(code)): \(message)" }
}

/// Client over the TBBN Platform API — Phase 0-13 resources. An `actor` since `URLSession`
/// requests can run concurrently across an app; every resource call is safely serialized
/// through this type without callers needing their own locking.
public actor TbbnClient {
    private let baseUrl: String
    private let apiKey: String?
    private let accessToken: String?
    private let session: URLSession

    public lazy var auth = AuthResource(client: self)
    public lazy var merchants = MerchantsResource(client: self)
    public lazy var apiKeys = ApiKeysResource(client: self)
    public lazy var sellers = SellersResource(client: self)
    public lazy var listings = ListingsResource(client: self)
    public lazy var catalog = CatalogResource(client: self)
    public lazy var media = MediaResource(client: self)
    public lazy var directory = DirectoryResource(client: self)
    public lazy var search = SearchResource(client: self)
    public lazy var tradeEngine = TradeEngineResource(client: self)
    public lazy var currency = CurrencyResource(client: self)
    public lazy var localization = LocalizationResource(client: self)
    public lazy var matching = MatchingResource(client: self)
    public lazy var recommendations = RecommendationsResource(client: self)
    public lazy var offers = OffersResource(client: self)
    public lazy var reservations = ReservationsResource(client: self)
    public lazy var tradeSessions = TradeSessionsResource(client: self)
    public lazy var checkout = CheckoutResource(client: self)
    public lazy var billing = BillingResource(client: self)
    public lazy var notifications = NotificationsResource(client: self)
    public lazy var webhooks = WebhooksResource(client: self)
    public lazy var auditLogs = AuditLogsResource(client: self)
    public lazy var moderation = ModerationResource(client: self)
    public lazy var fraud = FraudResource(client: self)
    public lazy var reputation = ReputationResource(client: self)
    public lazy var analytics = AnalyticsResource(client: self)
    public lazy var features = FeaturesResource(client: self)
    public lazy var sandbox = SandboxResource(client: self)

    public init(baseUrl: String, apiKey: String? = nil, accessToken: String? = nil, session: URLSession = .shared) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
        self.accessToken = accessToken
        self.session = session
    }

    /// Issues an HTTP request against the TBBN API and decodes the JSON response as `T`.
    /// Internal — resource types call this; not intended for direct use.
    func request<T: Decodable>(
        _ method: String,
        _ path: String,
        body: [String: Any?]? = nil,
        extraHeaders: [String: String] = [:]
    ) async throws -> T? {
        var request = URLRequest(url: URL(string: "\(baseUrl)\(path)")!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = apiKey ?? accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        for (key, value) in extraHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        if let body {
            request.httpBody = try JSONSerialization.data(withJSONObject: compact(body))
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TbbnApiError(status: 0, code: "NETWORK_ERROR", message: "No HTTP response", requestId: nil)
        }

        if httpResponse.statusCode == 204 {
            return nil
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let envelope = try? JSONDecoder().decode(ErrorEnvelope.self, from: data)
            throw TbbnApiError(
                status: httpResponse.statusCode,
                code: envelope?.error?.code ?? "UNKNOWN_ERROR",
                message: envelope?.error?.message ?? "Unknown error",
                requestId: envelope?.error?.requestId
            )
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    private func compact(_ dict: [String: Any?]) -> [String: Any] {
        dict.compactMapValues { $0 }
    }
}

struct ErrorEnvelope: Decodable {
    struct ErrorBody: Decodable {
        let code: String?
        let message: String?
        let requestId: String?
    }
    let error: ErrorBody?
}

/// Builds the Idempotency-Key header, matching sdk-js's idempotencyHeader() helper.
func idempotencyHeader(_ key: String?) -> [String: String] {
    key.map { ["Idempotency-Key": $0] } ?? [:]
}

/// Appends non-null query parameters to a path, matching sdk-js's withQuery() helper.
func withQuery(_ path: String, _ query: [String: Any?]) -> String {
    var components = URLComponents(string: path)!
    let items = query.compactMap { key, value -> URLQueryItem? in
        guard let value else { return nil }
        return URLQueryItem(name: key, value: "\(value)")
    }
    if items.isEmpty { return path }
    components.queryItems = items
    return components.string ?? path
}

/// Any-decodable box for endpoints whose response shape isn't a fixed model.
public struct AnyDecodable: Decodable {
    public let value: Any

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode([String: AnyDecodable].self) {
            value = v.mapValues { $0.value }
        } else if let v = try? container.decode([AnyDecodable].self) {
            value = v.map { $0.value }
        } else if let v = try? container.decode(String.self) {
            value = v
        } else if let v = try? container.decode(Double.self) {
            value = v
        } else if let v = try? container.decode(Bool.self) {
            value = v
        } else {
            value = NSNull()
        }
    }
}

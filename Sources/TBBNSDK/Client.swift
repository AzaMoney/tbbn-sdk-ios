import Foundation

/// Thrown for any non-2xx API response. Reads the documented
/// `{ "error": { "code", "message", "requestId" } }` envelope as well as the
/// `{ "code", "message", "details" }` and `{ "statusCode", "message", "error" }` bodies some
/// endpoints return, so `message` is always the API's own explanation.
public struct TbbnApiError: Error, CustomStringConvertible, @unchecked Sendable {
    public let status: Int
    public let code: String
    public let message: String
    public let requestId: String?
    /// Extra structured context some errors carry (for example which field failed), decoded with
    /// `JSONSerialization`.
    public let details: Any?

    public init(status: Int, code: String, message: String, requestId: String?, details: Any? = nil) {
        self.status = status
        self.code = code
        self.message = message
        self.requestId = requestId
        self.details = details
    }

    public var description: String { "TbbnApiError(\(status), \(code)): \(message)" }

    /// Builds the error from a response body, matching sdk-js's `parseApiError`.
    static func fromBody(status: Int, data: Data) -> TbbnApiError {
        let root = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        let envelope = root?["error"] as? [String: Any]
        let source = envelope ?? root ?? [:]

        func text(_ value: Any?) -> String? {
            if let s = value as? String, !s.isEmpty { return s }
            if let list = value as? [Any] {
                let parts = list.compactMap { $0 as? String }
                return parts.isEmpty ? nil : parts.joined(separator: "; ")
            }
            return nil
        }

        var code = source["code"] as? String
        if code == nil, envelope == nil, let label = root?["error"] as? String {
            code = label.uppercased().replacingOccurrences(of: " ", with: "_")
        }
        return TbbnApiError(
            status: status,
            code: code ?? "UNKNOWN_ERROR",
            message: text(source["message"]) ?? "Request failed with status \(status)",
            requestId: source["requestId"] as? String,
            details: source["details"]
        )
    }
}

/// Client over the TBBN Platform API. An `actor` since `URLSession`
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
    public lazy var tradeSessions = TradeSessionsResource(client: self)
    public lazy var checkout = CheckoutResource(client: self)
    public lazy var billing = BillingResource(client: self)
    public lazy var notifications = NotificationsResource(client: self)
    public lazy var webhooks = WebhooksResource(client: self)
    public lazy var moderation = ModerationResource(client: self)
    public lazy var fraud = FraudResource(client: self)
    public lazy var reputation = ReputationResource(client: self)
    public lazy var analytics = AnalyticsResource(client: self)
    public lazy var features = FeaturesResource(client: self)
    public lazy var sandbox = SandboxResource(client: self)
    public lazy var oauthClients = OAuthClientsResource(client: self)
    public lazy var oauthLink = OAuthLinkResource(client: self)
    public lazy var businesses = BusinessesResource(client: self)
    public lazy var branches = BranchesResource(client: self)
    public lazy var businessMerchantLinks = BusinessMerchantLinksResource(client: self)
    public lazy var space = SpaceResource(client: self)
    public lazy var merchantFeed = MerchantFeedResource(client: self)
    public lazy var reviews = ReviewsResource(client: self)
    public lazy var status = StatusResource(client: self)

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
            throw TbbnApiError.fromBody(status: httpResponse.statusCode, data: data)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    private func compact(_ dict: [String: Any?]) -> [String: Any] {
        dict.compactMapValues { $0 }
    }
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

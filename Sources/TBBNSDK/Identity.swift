import Foundation

public final class AuthResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func requestMerchantOtp(email: String) async throws {
        let _: AnyDecodable? = try await client.request("POST", "/v1/auth/merchant/otp/request", body: ["email": email])
    }

    public func verifyMerchantOtp(email: String, code: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/auth/merchant/otp/verify", body: ["email": email, "code": code])
    }

    public func requestSellerOtp(email: String) async throws {
        let _: AnyDecodable? = try await client.request("POST", "/v1/auth/seller/otp/request", body: ["email": email])
    }

    public func verifySellerOtp(email: String, code: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/auth/seller/otp/verify", body: ["email": email, "code": code])
    }

    public func requestMagicLink(email: String) async throws {
        let _: AnyDecodable? = try await client.request("POST", "/v1/auth/seller/magic-link/request", body: ["email": email])
    }

    public func consumeMagicLink(token: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/auth/seller/magic-link/consume?token=\(token.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? token)")
    }

    public func refresh(refreshToken: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/auth/refresh", body: ["refreshToken": refreshToken])
    }

    public func logout(refreshToken: String) async throws {
        let _: AnyDecodable? = try await client.request("POST", "/v1/auth/logout", body: ["refreshToken": refreshToken])
    }

    public func me() async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/auth/me")
    }
}

public final class MerchantsResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func create(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/merchants", body: input)
    }

    public func get(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/merchants/\(id)")
    }

    public func update(id: String, patch: [String: Any?], idempotencyKey: String? = nil) async throws -> AnyDecodable? {
        try await client.request("PATCH", "/v1/merchants/\(id)", body: patch, extraHeaders: idempotencyHeader(idempotencyKey))
    }

    public func submitApplication(id: String, submittedDocs: [String: Any?]? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/merchants/\(id)/submit-application", body: ["submittedDocs": submittedDocs])
    }

    public func applicationStatus(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/merchants/\(id)/application-status")
    }

    public func inviteUser(id: String, email: String, role: String, idempotencyKey: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/merchants/\(id)/users/invite", body: ["email": email, "role": role], extraHeaders: idempotencyHeader(idempotencyKey))
    }

    public func listUsers(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/merchants/\(id)/users")
    }

    public func changeRole(id: String, userId: String, role: String, idempotencyKey: String? = nil) async throws -> AnyDecodable? {
        try await client.request("PATCH", "/v1/merchants/\(id)/users/\(userId)/role", body: ["role": role], extraHeaders: idempotencyHeader(idempotencyKey))
    }
}

public final class ApiKeysResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func create(merchantId: String, environment: String, scopes: [String], idempotencyKey: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/api-keys", body: ["merchantId": merchantId, "environment": environment, "scopes": scopes], extraHeaders: idempotencyHeader(idempotencyKey))
    }

    public func list(merchantId: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/api-keys?merchantId=\(merchantId)")
    }

    public func rotate(id: String, idempotencyKey: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/api-keys/\(id)/rotate", extraHeaders: idempotencyHeader(idempotencyKey))
    }

    public func revoke(id: String) async throws {
        let _: AnyDecodable? = try await client.request("DELETE", "/v1/api-keys/\(id)")
    }
}

public final class SellersResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func verify(_ input: [String: Any?], idempotencyKey: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/merchant/sellers/verify", body: input, extraHeaders: idempotencyHeader(idempotencyKey))
    }

    public func requestLinkOtp(linkRequestId: String) async throws {
        let _: AnyDecodable? = try await client.request("POST", "/v1/sellers/link/otp/request", body: ["linkRequestId": linkRequestId])
    }

    public func verifyEmail(linkRequestId: String, code: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/sellers/link/otp/verify-email", body: ["linkRequestId": linkRequestId, "code": code])
    }

    public func verifyPhone(linkRequestId: String, code: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/sellers/link/otp/verify-phone", body: ["linkRequestId": linkRequestId, "code": code])
    }

    public func get(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/sellers/\(id)")
    }

    public func unlink(id: String, merchantId: String, idempotencyKey: String? = nil) async throws {
        let _: AnyDecodable? = try await client.request("POST", "/v1/sellers/\(id)/unlink", body: ["merchantId": merchantId], extraHeaders: idempotencyHeader(idempotencyKey))
    }
}

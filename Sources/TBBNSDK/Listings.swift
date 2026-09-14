// Status: WORKING (source only) — untested. See Package.swift header for details.

import Foundation

public final class ListingsResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func upsert(_ input: [String: Any?], idempotencyKey: String? = nil) async throws -> AnyDecodable? {
        try await client.request("POST", "/merchant/listings", body: input, extraHeaders: idempotencyHeader(idempotencyKey))
    }

    public func update(id: String, input: [String: Any?], idempotencyKey: String? = nil) async throws -> AnyDecodable? {
        try await client.request("PUT", "/merchant/listings/\(id)", body: input, extraHeaders: idempotencyHeader(idempotencyKey))
    }

    public func remove(id: String) async throws {
        let _: AnyDecodable? = try await client.request("DELETE", "/merchant/listings/\(id)")
    }

    public func updateAvailability(id: String, status: String) async throws -> AnyDecodable? {
        try await client.request("POST", "/merchant/listings/\(id)/availability", body: ["status": status])
    }

    public func replaceWants(id: String, wants: [[String: Any?]]) async throws -> AnyDecodable? {
        try await client.request("PUT", "/merchant/listings/\(id)/wants", body: ["wants": wants])
    }

    public func getWants(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/merchant/listings/\(id)/wants")
    }

    public func get(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/listings/\(id)")
    }

    public func list(query: [String: Any?] = [:]) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/listings", query))
    }
}

public final class CatalogResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func categories() async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/catalog/categories")
    }

    public func subcategories(category: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/catalog/categories/\(category.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? category)/subcategories")
    }

    public func brands(category: String? = nil, subcategory: String? = nil) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/catalog/brands", ["category": category, "subcategory": subcategory]))
    }
}

public final class MediaResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func ingest(images: [String]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/media/ingest", body: ["images": images])
    }
}

public final class DirectoryResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func list(query: [String: Any?] = [:]) async throws -> AnyDecodable? {
        try await client.request("GET", withQuery("/v1/directory/listings", query))
    }

    public func get(id: String) async throws -> AnyDecodable? {
        try await client.request("GET", "/v1/directory/listings/\(id)")
    }
}

public final class SearchResource {
    private unowned let client: TbbnClient
    init(client: TbbnClient) { self.client = client }

    public func listings(_ input: [String: Any?]) async throws -> AnyDecodable? {
        try await client.request("POST", "/v1/search/listings", body: input)
    }
}

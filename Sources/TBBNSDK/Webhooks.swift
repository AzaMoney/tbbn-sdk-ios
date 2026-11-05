import Foundation
import Crypto

private let replayWindowSeconds: Double = 5 * 60

/// Verifies the X-TBBN-Signature header format `t=<unix_ts>,v1=<hmac_sha256_hex>`. For a day after
/// a signing secret is rotated the header carries a `v1` for each secret; matching any one is
/// enough. See docs/architecture/event-webhook-catalog.md. Ported faithfully from
/// packages/sdk-js/src/webhooks.ts — same algorithm, same replay window. Uses swift-crypto
/// (Apple's own HMAC implementation, cross-platform).
public func verifyWebhookSignature(rawBody: String, signatureHeader: String, signingSecret: String, now: Double = Date().timeIntervalSince1970) -> Bool {
    var timestampStr: String?
    var signatures: [String] = []
    for pair in signatureHeader.split(separator: ",") {
        let kv = pair.split(separator: "=", maxSplits: 1)
        guard kv.count == 2 else { continue }
        if kv[0] == "t" { timestampStr = String(kv[1]) }
        if kv[0] == "v1" { signatures.append(String(kv[1])) }
    }

    guard let timestampStr, let timestamp = Double(timestampStr), !signatures.isEmpty else {
        return false
    }
    guard abs(now - timestamp) <= replayWindowSeconds else { return false }

    let key = SymmetricKey(data: Data(signingSecret.utf8))
    let message = Data("\(Int(timestamp)).\(rawBody)".utf8)
    let expected = HMAC<SHA256>.authenticationCode(for: message, using: key)
    let expectedHex = expected.map { String(format: "%02x", $0) }.joined()

    return signatures.contains { constantTimeEquals(expectedHex, $0) }
}

private func constantTimeEquals(_ a: String, _ b: String) -> Bool {
    guard a.count == b.count else { return false }
    var result: UInt8 = 0
    for (x, y) in zip(a.utf8, b.utf8) {
        result |= x ^ y
    }
    return result == 0
}

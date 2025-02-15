import CommonCrypto
import Foundation

extension Data {
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }

    var sha256: Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(count), &digest)
        }
        return Data(digest)
    }

}

extension String {
    func sha256(salt: String) -> Data {
        return (self + salt).data(using: .utf8)!.sha256
    }
}

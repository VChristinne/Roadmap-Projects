import CryptoKit
import Foundation

struct InputHasher {
    static func hash(input: String) -> String {
        let inputData = Data(input.utf8)
        let hashData = SHA256.hash(data: inputData)
        let hashString = hashData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}

let emailHash = InputHasher.hash(input: "user@example.com")
print(emailHash)

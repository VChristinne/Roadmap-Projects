import CryptoKit
import Foundation

struct Hasher {
    static func generateSalt() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz123456789"
        var salt = ""
        for _ in 0..<5 {
            if let randomLetter = letters.randomElement() {
                salt.append(randomLetter)
            }
        }
        return salt
    }

    static func hashPass(password: String, salt: String) -> String {
        let passWithSalt = password + salt
        let hashedPass = SHA256.hash(data: Data(passWithSalt.utf8))
        return hashedPass.compactMap { String(format: "%02x", $0) }.joined()
    }
}

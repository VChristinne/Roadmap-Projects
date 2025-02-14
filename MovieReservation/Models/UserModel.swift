import SwiftUI

struct ClientModel: Identifiable {
    var id = UUID().uuidString
    var username: String
    var email: String
    var password: String
}

struct AdminModel: Identifiable {
    var id = UUID().uuidString
    var username: String
    var email: String
    var password: String
}

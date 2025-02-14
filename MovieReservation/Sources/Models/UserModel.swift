import SwiftUI

protocol User: Identifiable, Codable {
    var id: UUID { get set }
    var username: String { get set }
    var email: String { get set }
    var password: String { get set }
    var permissions: [UserPermission] { get set }
}

struct ClientModel: User {
    var id = UUID()
    var username: String
    var email: String
    var password: String
    var permissions: [UserPermission]
}

struct AdminModel: User {
    var id = UUID()
    var username: String
    var email: String
    var password: String
    var permissions: [UserPermission]
}

struct UserPermission: Codable {
    var editProfile: Bool
    var manageUser: Bool
    var manageMovie: Bool
    var manageShowtime: Bool
}

import SwiftUI

struct UserModel: Identifiable, Codable {
    var id = UUID()
    var username: String
    var email: String
    var password: String
    var type: UserType
    var permission: UserPermission
}

enum UserType: Codable {
    case client
    case admin
}

enum Permission {
    case editProfile
    case manageUser
    case manageMovie
    case manageReservation
}

struct UserPermission: Codable {
    var editProfile: Bool
    var manageUser: Bool
    var manageMovie: Bool
    var manageReservation: Bool
}

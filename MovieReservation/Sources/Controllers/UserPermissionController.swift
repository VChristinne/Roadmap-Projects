class UserPermissionController {
    static let shared = UserPermissionController()

    func hasPermission(_ user: UserModel, for permission: Permission) -> Bool {
        switch permission {
        case .editProfile:
            return user.permission.editProfile
        case .manageUser:
            return user.permission.manageUser
        case .manageMovie:
            return user.permission.manageMovie
        case .manageReservation:
            return user.permission.manageReservation
        }
    }

    func getDefaultPermissions(for userType: UserType) -> UserPermission {
        switch userType {
        case .client:
            return UserPermission(
                editProfile: true,
                manageUser: false,
                manageMovie: false,
                manageReservation: true
            )
        case .admin:
            return UserPermission(
                editProfile: true,
                manageUser: true,
                manageMovie: true,
                manageReservation: true
            )
        }
    }

    func updatePermissions(for user: inout UserModel, with newPermission: UserPermission) {
        user.permission = newPermission
    }
}

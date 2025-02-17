import Foundation

func main() {
    var client = UserModel(
        username: "client",
        email: "client@example.com",
        password: "987654",
        type: .client,
        permission: UserPermissionController.shared.getDefaultPermissions(for: .client)
    )

    var admin = UserModel(
        username: "admin",
        email: "admin@example.com",
        password: "123456",
        type: .admin,
        permission: UserPermissionController.shared.getDefaultPermissions(for: .admin)
    )

    print("\nClientModel:")
    print("ID: \(client.id)")
    print("Username: \(client.username)")
    print("Email: \(client.email)")
    print("Password (hashed): \(InputHasher.hash(input: client.password))")
    print("Permissions: \(client.permission)")

    print("--------------------")

    print("\nAdminModel:")
    print("ID: \(admin.id)")
    print("Username: \(admin.username)")
    print("Email: \(admin.email)")
    print("Password (hashed): \(InputHasher.hash(input: admin.password))")
    print("Permissions: \(admin.permission)")

    UserPermissionController.shared.updatePermissions(
        for: &client,
        with: UserPermission(
            editProfile: true,
            manageUser: true,
            manageMovie: false,
            manageReservation: true
        )
    )

    print("\nUpdated ClientModel: \(client.permission)")
}

main()

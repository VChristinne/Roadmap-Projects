import Foundation

func main() {
    var client = ClientModel(
        username: "user1",
        email: "user1@example.com",
        password: PasswordHasher.hash(input: "password123"),
        permissions: []
    )

    var admin = AdminModel(
        username: "admin1",
        email: "admin1@example.com",
        password: PasswordHasher.hash(input: "password123"),
        permissions: [
            UserPermission(manageUser: true, manageMovie: true, manageShowtime: true)
        ]
    )

    print("ClientModel:")
    print("ID: \(client.id)")
    print("Username: \(client.username)")
    print("Email: \(client.email)")
    print("Password (hashed): \(client.password)")
    print("Permissions: \(client.permissions)")

    print("\nAdminModel:")
    print("ID: \(admin.id)")
    print("Username: \(admin.username)")
    print("Email: \(admin.email)")
    print("Password (hashed): \(admin.password)")
    print("Permissions: \(admin.permissions)")
}

main()

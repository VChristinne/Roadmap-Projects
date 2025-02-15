import Foundation

func main() {
    let client = ClientModel(
        username: "user1",
        email: "user1@example.com",
        password: InputHasher.hash(input: "password123"),
        permissions: [
            UserPermission(editProfile: true, manageUser: false, manageMovie: false, manageShowtime: false)
        ]
    )

    let admin = AdminModel(
        username: "admin1",
        email: "admin1@example.com",
        password: InputHasher.hash(input: "password123"),
        permissions: [
            UserPermission(editProfile: true, manageUser: true, manageMovie: true, manageShowtime: true)
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

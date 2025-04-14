import Foundation

func main() {
    while true {
        menu()
        let option = readLine() ?? ""

        switch option {
        case "1":
            register()
        case "2":
            login()
        case "3":
            print("Goodbye!")
            return
        default:
            print("Invalid option")
        }
    }
}

func menu() {
    print("\n=== Movie Reservation System ===")
    print("1 - Register")
    print("2 - Login")
    print("3 - Exit")
    print("Choose an option: ")
}

func register() {
    print("\n=== Register ===")
    print("Enter your username: ")
    let username = readLine() ?? ""
    print("Enter your email: ")
    let email = readLine() ?? ""
    print("Enter your password: ")
    let password = readLine() ?? ""
    print("Enter your type (1 for Client, 2 for Admin): ")
    let typeInput = readLine() ?? ""

    let userType: UserType
    switch typeInput {
    case "1":
        userType = .client
    case "2":
        userType = .admin
    default:
        print("Invalid user type. Defaulting to client.")
        userType = .client
    }

    if let user = RegisterUserController.shared.registerUser(
        username: username,
        email: email,
        password: password,
        type: userType
    ) {
        print("\nRegistration successful!")
        print("Welcome, \(user.username)!")
    } else {
        print("\nRegistration failed. Email might already be in use.")
    }
}

func login() {
    print("\n=== Login ===")
    print("Enter your email: ")
    let email = readLine() ?? ""
    print("Enter your password: ")
    let password = readLine() ?? ""

    if let user = RegisterUserController.shared.loginUser(email: email, password: password) {
        print("\nLogin successful!")
        print("Welcome back, \(user.username)!")
    } else {
        print("\nLogin failed. Invalid email or password.")
    }
}

main()

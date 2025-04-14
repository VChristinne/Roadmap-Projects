/*
Registro:
Input da senha;
Gera um Salt aleatorio do Random;
Concatena senha original + salt gerado;
Hash dessa concatenação e salva no json: hashedPass, salt gerado;

Login:
Obtem a senha e salt do json;
Concatena os dois, faz o hash novamente;
Compara com o hash no json.
*/

import Foundation

class RegisterUserController {
    static let shared = RegisterUserController()
    private let jsonFileName = "clients.json"

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    private func loadUsers() -> [UserModel] {
        let fileURL = getDocumentsDirectory().appendingPathComponent(jsonFileName)

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([UserModel].self, from: data)
        } catch {
            return []
        }
    }

    private func saveUsers(_ users: [UserModel]) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(jsonFileName)

        do {
            let data = try JSONEncoder().encode(users)
            try data.write(to: fileURL)
        } catch {
            print("Error saving users: \(error)")
        }
    }

    func registerUser(username: String, email: String, password: String, type: UserType)
        -> UserModel?
    {
        var users = loadUsers()

        if users.contains(where: { $0.email == email }) {
            return nil
        }

        let salt = Hasher.generateSalt()
        let hashedPass = Hasher.hashPass(password: password, salt: salt)

        let user = UserModel(
            username: username,
            email: email,
            password: hashedPass,
            salt: salt,
            type: type,
            permission: UserPermissionController.shared.getDefaultPermissions(for: type)
        )

        users.append(user)
        saveUsers(users)
        return user
    }

    func loginUser(email: String, password: String) -> UserModel? {
        let users = loadUsers()
        guard let user = users.first(where: { $0.email == email }) else {
            return nil
        }
        let hashedPass = Hasher.hashPass(password: password, salt: user.salt)
        return hashedPass == user.password ? user : nil
    }
}

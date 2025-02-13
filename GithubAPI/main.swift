import Foundation
import SwiftUI

struct GitHubUser: Codable {
    let login: String
    let eventsUrl: String
}

struct GitHubEvent: Codable {
    let type: String
    let createdAt: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidUser
}

func getUser(username: String) async throws -> GitHubUser {
    guard let endpoint = URL(string: "https://api.github.com/users/\(username)") else {
        throw GHError.invalidURL
    }

    let (userData, userResponse) = try await URLSession.shared.data(from: endpoint)

    guard (userResponse as? HTTPURLResponse)?.statusCode == 200 else {
        throw GHError.invalidResponse
    }

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(GitHubUser.self, from: userData)
}

func getEvents(url: String) async throws -> [GitHubEvent] {
    let publicEventsUrl = url.replacingOccurrences(of: "{/privacy}", with: "/public")

    guard let endpoint = URL(string: publicEventsUrl) else {
        throw GHError.invalidURL
    }

    let (eventsData, eventsResponse) = try await URLSession.shared.data(from: endpoint)

    guard (eventsResponse as? HTTPURLResponse)?.statusCode == 200 else {
        throw GHError.invalidResponse
    }

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode([GitHubEvent].self, from: eventsData)
}

if CommandLine.arguments.count != 2 {
    print("Please provide a GitHub username")
    print("Usage: swift main.swift <username>")
    exit(1)
}

let username = CommandLine.arguments[1]

Task {
    do {
        let user = try await getUser(username: username)
        let events = try await getEvents(url: user.eventsUrl)
        print(
            """
            User: \(user.login)
            Recent Events: \(events.count)
            """)

        for event in events.prefix(5) {
            print(
                """
                Event: \(event.type) @ Created At: \(event.createdAt)
                """)
        }
    } catch {
        print(error)
    }
}

RunLoop.main.run(until: Date(timeIntervalSinceNow: 2))

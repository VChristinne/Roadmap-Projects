import Foundation
import SwiftUI

struct GitHubUser: Codable {
    let login: String
    let eventsUrl: String
}

struct GitHubRepo: Codable {
    let name: String
}

struct GitHubEvent: Codable {
    let type: String
    let createdAt: String
    let repo: GitHubRepo
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

    guard let httpResponse = eventsResponse as? HTTPURLResponse else {
        throw GHError.invalidResponse
    }

    print("Events Status Code: \(httpResponse.statusCode)")

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode([GitHubEvent].self, from: eventsData)
}

func getRepos(username: String) async throws -> [GitHubRepo] {
    guard let endpoint = URL(string: "https://api.github.com/users/\(username)/repos") else {
        throw GHError.invalidURL
    }

    let (reposData, reposResponse) = try await URLSession.shared.data(from: endpoint)

    guard let httpResponse = reposResponse as? HTTPURLResponse else {
        throw GHError.invalidResponse
    }

    print("Repos Status Code: \(httpResponse.statusCode)")

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode([GitHubRepo].self, from: reposData)
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
        async let events = getEvents(url: user.eventsUrl)
        async let repos = getRepos(username: username)

        let (userEvents, userRepos) = try await (events, repos)

        print(
            """
            User: \(user.login)
            Recent Events: \(userEvents.count)
            Repositories: \(userRepos.count)
            """)

        for event in userEvents.prefix(5) {
            print(
                """
                Event: \(event.type) at \(event.repo.name) @ Date: \(event.createdAt)
                """)
        }
    } catch {
        print(error)
    }
}

RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))

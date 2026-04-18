import AuthenticationServices
import Foundation
import UIKit

class WebAuthContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
}

enum StravaKeys: Sendable {
    static let accessToken = "strava_access_token"
    static let refreshToken = "strava_refresh_token"
    static let expiresAt = "strava_expires_at"
}

enum StravaError: Error, Sendable {
    case missingCredentials
    case invalidResponse
    case tokenExpired
    case refreshFailed
    case notConnected
}

@Observable
final class StravaService {
    private let clientId: String = Config.EXPO_PUBLIC_STRAVA_CLIENT_ID
    private let clientSecret: String = Config.EXPO_PUBLIC_STRAVA_CLIENT_SECRET
    private let redirectUri: String = "selfsport://strava-callback"
    private let baseURL: String = "https://www.strava.com"
    private let apiURL: String = "https://www.strava.com/api/v3"
    private var activeRefreshTask: Task<Void, Error>?
    private let tokenSync = SupabaseTokenService.shared

    var isConnected: Bool {
        KeychainHelper.loadString(forKey: StravaKeys.accessToken) != nil
    }

    func buildAuthURL() -> URL? {
        guard !clientId.isEmpty else { return nil }
        var components = URLComponents(string: "\(baseURL)/oauth/mobile/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "approval_prompt", value: "auto"),
            URLQueryItem(name: "scope", value: "activity:read_all,profile:read_all")
        ]
        return components?.url
    }

    func authenticate() async throws {
        guard let authURL = buildAuthURL() else {
            throw StravaError.missingCredentials
        }

        let contextProvider = WebAuthContextProvider()
        let callbackURL: URL = try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "selfsport"
            ) { url, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: StravaError.invalidResponse)
                }
            }
            session.presentationContextProvider = contextProvider
            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }

        guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw StravaError.invalidResponse
        }

        try await exchangeToken(code: code)
    }

    func handleCallbackURL(_ url: URL) async throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              url.host == "strava-callback",
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return
        }
        try await exchangeToken(code: code)
    }

    private func exchangeToken(code: String) async throws {
        let url = URL(string: "\(baseURL)/oauth/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "grant_type": "authorization_code"
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StravaError.invalidResponse
        }

        let tokenResponse = try JSONDecoder().decode(StravaTokenResponse.self, from: data)
        print("[Strava] ✅ Token exchange success — athleteId: \(tokenResponse.athlete?.id.description ?? "nil"), expiresAt: \(tokenResponse.expiresAt)")
        saveTokens(tokenResponse)

        await tokenSync.syncTokens(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            expiresAt: tokenResponse.expiresAt,
            athleteId: tokenResponse.athlete?.id
        )
    }

    func refreshTokenIfNeeded(force: Bool = false) async throws {
        guard let expiresAtString = KeychainHelper.loadString(forKey: StravaKeys.expiresAt),
              let expiresAt = Int(expiresAtString) else {
            throw StravaError.notConnected
        }

        let now = Int(Date().timeIntervalSince1970)
        if !force && now < expiresAt - 300 { return }

        try await performTokenRefresh()
    }

    func forceRefreshToken() async throws {
        try await performTokenRefresh()
    }

    private func performTokenRefresh() async throws {
        if let existing = activeRefreshTask {
            try await existing.value
            return
        }

        let task = Task<Void, Error> {
            defer { activeRefreshTask = nil }

            guard let refreshToken = KeychainHelper.loadString(forKey: StravaKeys.refreshToken) else {
                throw StravaError.notConnected
            }

            let url = URL(string: "\(baseURL)/oauth/token")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: String] = [
                "client_id": clientId,
                "client_secret": clientSecret,
                "refresh_token": refreshToken,
                "grant_type": "refresh_token"
            ]
            request.httpBody = try JSONEncoder().encode(body)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw StravaError.refreshFailed
            }

            let tokenResponse = try JSONDecoder().decode(StravaTokenResponse.self, from: data)
            saveTokens(tokenResponse)
            await tokenSync.syncTokens(
                accessToken: tokenResponse.accessToken,
                refreshToken: tokenResponse.refreshToken,
                expiresAt: tokenResponse.expiresAt
            )
        }

        activeRefreshTask = task
        try await task.value
    }

    func fetchActivities(page: Int = 1, perPage: Int = 20, after: Date? = nil, before: Date? = nil) async throws -> [StravaActivity] {
        try await refreshTokenIfNeeded()
        return try await performFetchActivities(page: page, perPage: perPage, after: after, before: before, isRetry: false)
    }

    private func performFetchActivities(page: Int, perPage: Int, after: Date?, before: Date?, isRetry: Bool) async throws -> [StravaActivity] {
        guard let accessToken = KeychainHelper.loadString(forKey: StravaKeys.accessToken) else {
            throw StravaError.notConnected
        }

        var components = URLComponents(string: "\(apiURL)/athlete/activities")!
        var queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        if let after {
            queryItems.append(URLQueryItem(name: "after", value: "\(Int(after.timeIntervalSince1970))"))
        }
        if let before {
            queryItems.append(URLQueryItem(name: "before", value: "\(Int(before.timeIntervalSince1970))"))
        }
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            if !isRetry {
                try await forceRefreshToken()
                return try await performFetchActivities(page: page, perPage: perPage, after: after, before: before, isRetry: true)
            }
            throw StravaError.tokenExpired
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StravaError.invalidResponse
        }

        return try JSONDecoder().decode([StravaActivity].self, from: data)
    }

    func fetchActivityDetail(id: Int) async throws -> StravaActivityDetail {
        try await refreshTokenIfNeeded()
        return try await performFetchActivityDetail(id: id, isRetry: false)
    }

    private func performFetchActivityDetail(id: Int, isRetry: Bool) async throws -> StravaActivityDetail {
        guard let accessToken = KeychainHelper.loadString(forKey: StravaKeys.accessToken) else {
            throw StravaError.notConnected
        }

        var components = URLComponents(string: "\(apiURL)/activities/\(id)")!
        components.queryItems = [
            URLQueryItem(name: "include_all_efforts", value: "true")
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            if !isRetry {
                try await forceRefreshToken()
                return try await performFetchActivityDetail(id: id, isRetry: true)
            }
            throw StravaError.tokenExpired
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw StravaError.invalidResponse
        }

        return try JSONDecoder().decode(StravaActivityDetail.self, from: data)
    }

    func disconnect() {
        KeychainHelper.delete(forKey: StravaKeys.accessToken)
        KeychainHelper.delete(forKey: StravaKeys.refreshToken)
        KeychainHelper.delete(forKey: StravaKeys.expiresAt)
        Task { await tokenSync.deleteTokens() }
    }

    private func saveTokens(_ response: StravaTokenResponse) {
        KeychainHelper.save(response.accessToken, forKey: StravaKeys.accessToken)
        KeychainHelper.save(response.refreshToken, forKey: StravaKeys.refreshToken)
        KeychainHelper.save("\(response.expiresAt)", forKey: StravaKeys.expiresAt)
    }
}

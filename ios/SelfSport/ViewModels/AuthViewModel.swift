import Foundation
import SwiftUI
import AuthenticationServices
import Supabase
import Auth

@Observable
final class AuthViewModel {
    var isAuthenticated: Bool = false
    var isLoading: Bool = true
    var userProfile: UserProfile?
    var errorMessage: String?
    var currentNonce: String?
    var isGoogleLoading: Bool = false
    private var authListenerTask: Task<Void, Never>?

    func startAuthListener() {
        authListenerTask?.cancel()
        authListenerTask = Task {
            for await (event, session) in await supabase.auth.authStateChanges {
                guard !Task.isCancelled else { return }
                switch event {
                case .initialSession:
                    if let session {
                        isAuthenticated = true
                        await fetchProfile(userId: session.user.id)
                    } else {
                        isAuthenticated = false
                    }
                    isLoading = false
                case .signedIn, .tokenRefreshed:
                    isAuthenticated = true
                    if let session {
                        await fetchProfile(userId: session.user.id)
                    }

                case .signedOut:
                    isAuthenticated = false
                    userProfile = nil
                default:
                    break
                }
            }
        }
    }

    func stopAuthListener() {
        authListenerTask?.cancel()
        authListenerTask = nil
    }

    func signInWithApple(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil

        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityTokenData = credential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                errorMessage = "Could not get Apple ID token"
                isLoading = false
                return
            }

            do {
                let session = try await supabase.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: identityToken
                    )
                )

                isAuthenticated = true

                let fullName: String? = {
                    if let nameComponents = credential.fullName {
                        let parts = [nameComponents.givenName, nameComponents.familyName].compactMap { $0 }
                        return parts.isEmpty ? nil : parts.joined(separator: " ")
                    }
                    return nil
                }()

                await upsertProfile(
                    userId: session.user.id,
                    email: credential.email ?? session.user.email,
                    fullName: fullName
                )
            } catch {
                errorMessage = error.localizedDescription
            }

        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }

    func signInWithGoogle() async {
        isGoogleLoading = true
        errorMessage = nil

        do {
            let session = try await supabase.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "selfsport://auth-callback")
            ) { (session: ASWebAuthenticationSession) in
                session.prefersEphemeralWebBrowserSession = true
            }

            isAuthenticated = true
            let currentSession = try await supabase.auth.session
            let user = currentSession.user

            let fullName = user.userMetadata["full_name"]?.stringValue
                ?? user.userMetadata["name"]?.stringValue
            let avatarUrl = user.userMetadata["avatar_url"]?.stringValue
                ?? user.userMetadata["picture"]?.stringValue

            await upsertProfile(
                userId: user.id,
                email: user.email,
                fullName: fullName,
                avatarUrl: avatarUrl
            )
        } catch {
            if (error as NSError).code != ASWebAuthenticationSessionError.canceledLogin.rawValue {
                errorMessage = error.localizedDescription
            }
        }

        isGoogleLoading = false
    }

    func signInWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            isAuthenticated = true
            await fetchProfile(userId: session.user.id)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signOut() async {
        do {
            try await supabase.auth.signOut()
            isAuthenticated = false
            userProfile = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func upsertProfile(userId: UUID, email: String?, fullName: String?, avatarUrl: String? = nil) async {
        var data: [String: String] = ["id": userId.uuidString]
        if let email { data["email"] = email }
        if let fullName { data["full_name"] = fullName }
        if let avatarUrl { data["avatar_url"] = avatarUrl }

        do {
            try await supabase
                .from("profiles")
                .upsert(data, onConflict: "id")
                .execute()

            await fetchProfile(userId: userId)
        } catch {
            // Profile table may not exist yet
        }
    }

    func fetchProfile(userId: UUID) async {
        do {
            let profile: UserProfile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            userProfile = profile
        } catch {
            // Profile table may not exist yet
        }
    }
}

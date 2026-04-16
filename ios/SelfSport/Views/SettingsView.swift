import SwiftUI

struct SettingsView: View {
    let userProfile: UserProfile?
    let isStravaConnected: Bool
    let onDisconnectStrava: () -> Void
    let onSignOut: () -> Void
    var onDeleteAccount: () async -> Bool = { false }
    @Environment(\.dismiss) private var dismiss
    @State private var showSignOutConfirmation: Bool = false
    @State private var showDisconnectStravaConfirmation: Bool = false
    @State private var showDeleteAccountConfirmation: Bool = false
    @State private var isDeletingAccount: Bool = false
    @State private var deleteErrorMessage: String?
    @State private var showDeleteError: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    profileSection
                    notificationsSection
                    stravaSection
                    sessionSection
                    dangerZoneSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color.black)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 17, weight: .regular, design: .serif).italic())
                        .foregroundStyle(Color.white.opacity(0.90))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.50))
                            .frame(width: 30, height: 30)
                            .background(Color.white.opacity(0.08), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.black)
        .confirmationDialog("Disconnect Strava", isPresented: $showDisconnectStravaConfirmation, titleVisibility: .visible) {
            Button("Disconnect", role: .destructive) {
                onDisconnectStrava()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your cached activities will be removed. You can reconnect anytime.")
        }
        .confirmationDialog("Sign Out", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                onSignOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showDeleteAccountConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    isDeletingAccount = true
                    let success = await onDeleteAccount()
                    isDeletingAccount = false
                    if success {
                        dismiss()
                    } else {
                        deleteErrorMessage = "We couldn't delete your account. Please try again or contact support."
                        showDeleteError = true
                    }
                }
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
        .alert("Deletion Failed", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteErrorMessage ?? "An error occurred.")
        }
    }

    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("DANGER ZONE", icon: "exclamationmark.triangle.fill")

            Button {
                showDeleteAccountConfirmation = true
            } label: {
                HStack {
                    Text("Delete Account")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(red: 1.0, green: 0.30, blue: 0.30))
                    Spacer()
                    if isDeletingAccount {
                        ProgressView()
                            .controlSize(.small)
                            .tint(Color(red: 1.0, green: 0.30, blue: 0.30))
                    } else {
                        Image(systemName: "trash")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(red: 1.0, green: 0.30, blue: 0.30).opacity(0.60))
                    }
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(cardBackground)
            .disabled(isDeletingAccount)
        }
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("PROFILE", icon: "person.fill")

            HStack(spacing: 14) {
                if let avatarUrl = userProfile?.avatarUrl, let url = URL(string: avatarUrl) {
                    Color.clear
                        .frame(width: 52, height: 52)
                        .overlay {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill().allowsHitTesting(false)
                                } else {
                                    avatarPlaceholder
                                }
                            }
                        }
                        .clipShape(Circle())
                } else {
                    avatarPlaceholder
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(userProfile?.fullName ?? "Athlete")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.92))

                    if let email = userProfile?.email {
                        Text(email)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(Color.white.opacity(0.40))
                    }
                }

                Spacer()
            }
            .padding(16)
            .background(cardBackground)
        }
    }

    private var avatarPlaceholder: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 52, height: 52)
            Text(initials)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.50))
        }
    }

    private var initials: String {
        guard let name = userProfile?.fullName, !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ")
        let first = parts.first.map { String($0.prefix(1)).uppercased() } ?? ""
        let last = parts.count > 1 ? String(parts.last!.prefix(1)).uppercased() : ""
        return first + last
    }

    private var stravaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("STRAVA", icon: "figure.run")

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Connection")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.white.opacity(0.80))

                        Text(isStravaConnected ? "Connected" : "Not connected")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(isStravaConnected ? Color(red: 0.30, green: 0.78, blue: 0.45) : Color.white.opacity(0.36))
                    }

                    Spacer()

                    Circle()
                        .fill(isStravaConnected ? Color(red: 0.30, green: 0.78, blue: 0.45) : Color.white.opacity(0.20))
                        .frame(width: 8, height: 8)
                }
                .padding(16)

                if isStravaConnected {
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 0.5)
                        .padding(.leading, 16)

                    Button {
                        showDisconnectStravaConfirmation = true
                    } label: {
                        HStack {
                            Text("Disconnect Strava")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color(red: 0.99, green: 0.32, blue: 0.14))
                            Spacer()
                            Image(systemName: "link.badge.plus")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(red: 0.99, green: 0.32, blue: 0.14).opacity(0.60))
                                .rotationEffect(.degrees(45))
                        }
                        .padding(16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(cardBackground)
        }
    }

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("NOTIFICATIONS", icon: "bell.fill")

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Push Notifications")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.white.opacity(0.80))

                        Text(NotificationService.shared.isAuthorized ? "Enabled" : "Disabled")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(NotificationService.shared.isAuthorized ? Color(red: 0.30, green: 0.78, blue: 0.45) : Color.white.opacity(0.36))
                    }

                    Spacer()

                    Circle()
                        .fill(NotificationService.shared.isAuthorized ? Color(red: 0.30, green: 0.78, blue: 0.45) : Color.white.opacity(0.20))
                        .frame(width: 8, height: 8)
                }
                .padding(16)

                if !NotificationService.shared.isAuthorized {
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 0.5)
                        .padding(.leading, 16)

                    Button {
                        if NotificationService.shared.hasBeenPrompted {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } else {
                            Task {
                                await NotificationService.shared.requestAuthorization()
                            }
                        }
                    } label: {
                        HStack {
                            Text(NotificationService.shared.hasBeenPrompted ? "Open Settings" : "Enable Notifications")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.white.opacity(0.80))
                            Spacer()
                            Image(systemName: NotificationService.shared.hasBeenPrompted ? "arrow.up.forward" : "bell.badge")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white.opacity(0.40))
                        }
                        .padding(16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(cardBackground)
        }
        .onAppear {
            Task { await NotificationService.shared.refreshAuthorizationStatus() }
        }
    }

    private var sessionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("SESSION", icon: "rectangle.portrait.and.arrow.right")

            Button {
                showSignOutConfirmation = true
            } label: {
                HStack {
                    Text("Sign Out")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(red: 1.0, green: 0.30, blue: 0.30))
                    Spacer()
                    Image(systemName: "arrow.right.square")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 1.0, green: 0.30, blue: 0.30).opacity(0.60))
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(cardBackground)
        }
    }

    private func sectionLabel(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.30))
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .tracking(2.4)
                .foregroundStyle(Color.white.opacity(0.30))
        }
        .padding(.leading, 4)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(0.04))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.07), lineWidth: 0.5)
            }
    }
}

#Preview {
    Color.black.sheet(isPresented: .constant(true)) {
        SettingsView(
            userProfile: UserProfile(id: UUID(), fullName: "Juan Pérez", email: "juan@email.com"),
            isStravaConnected: true,
            onDisconnectStrava: {},
            onSignOut: {}
        )
    }
    .preferredColorScheme(.dark)
}

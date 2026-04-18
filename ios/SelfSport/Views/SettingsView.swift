import SwiftUI

struct SettingsView: View {
    let userProfile: UserProfile?
    let isStravaConnected: Bool
    let isAppleHealthConnected: Bool
    let activeSource: ActiveSource
    let isConnecting: Bool
    let onDisconnectStrava: () -> Void
    let onConnectStrava: () -> Void
    let onDisconnectAppleHealth: () -> Void
    let onConnectAppleHealth: () -> Void
    let onSignOut: () -> Void
    var onDeleteAccount: () async -> Bool = { false }
    @Environment(\.dismiss) private var dismiss
    @State private var showSignOutConfirmation: Bool = false
    @State private var showDisconnectStravaConfirmation: Bool = false
    @State private var showDisconnectAppleHealthConfirmation: Bool = false
    @State private var showDeleteAccountConfirmation: Bool = false
    @State private var isDeletingAccount: Bool = false
    @State private var deleteErrorMessage: String?
    @State private var showDeleteError: Bool = false
    @State private var showConnectProvidersSheet: Bool = false
    @State private var showSadZoneDrawer: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    profileSection
                    notificationsSection
                    stravaSection
                    rateSection
                    instagramSection
                    sadZoneSection
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
                        .offset(y: 6)
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
        .confirmationDialog("Disconnect Apple Health", isPresented: $showDisconnectAppleHealthConfirmation, titleVisibility: .visible) {
            Button("Disconnect", role: .destructive) {
                onDisconnectAppleHealth()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Apple Health will no longer be your active source. Your workouts stay in Apple Health.")
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

    private var sadZoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("SAD ZONE", icon: "cloud.rain.fill")

            Button {
                showSadZoneDrawer = true
            } label: {
                HStack {
                    Text("Sad zone")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.50))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.25))
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(cardBackground)
        }
        .sheet(isPresented: $showSadZoneDrawer) {
            sadZoneDrawer
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(white: 0.06))
        }
    }

    private var sadZoneDrawer: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Image(systemName: "cloud.rain.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.30))
                Text("Sad zone")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.80))
            }
            .padding(.top, 28)
            .padding(.bottom, 24)

            VStack(spacing: 0) {
                Button {
                    showSadZoneDrawer = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showSignOutConfirmation = true
                    }
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

                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 0.5)
                    .padding(.horizontal, 16)

                Button {
                    showSadZoneDrawer = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showDeleteAccountConfirmation = true
                    }
                } label: {
                    HStack {
                        Text("Delete Account")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.40))
                        Spacer()
                        if isDeletingAccount {
                            ProgressView()
                                .controlSize(.small)
                                .tint(Color.white.opacity(0.40))
                        } else {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white.opacity(0.30))
                        }
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isDeletingAccount)
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.07), lineWidth: 0.5)
                    }
            )
            .padding(.horizontal, 20)

            Spacer()
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

    private var externalConnectionName: String {
        if activeSource == .appleHealth && isAppleHealthConnected { return "Apple Health" }
        if isStravaConnected { return "Strava" }
        return "None"
    }

    private var isAnySourceConnected: Bool {
        isStravaConnected || isAppleHealthConnected
    }

    private var stravaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("EXTERNAL CONNECTION", icon: "link")

            if isAnySourceConnected {
                connectedSourceRow
            } else {
                Button {
                    showConnectProvidersSheet = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Connected app")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.white.opacity(0.80))
                            Text("None")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.white.opacity(0.36))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.25))
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background(cardBackground)
            }
        }
        .sheet(isPresented: $showConnectProvidersSheet) {
            ConnectProvidersSheet(
                isConnecting: isConnecting,
                onConnectStrava: {
                    showConnectProvidersSheet = false
                    onConnectStrava()
                },
                onConnectAppleHealth: {
                    showConnectProvidersSheet = false
                    onConnectAppleHealth()
                }
            )
            .presentationDetents([.height(480)])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color(white: 0.08))
        }
    }

    private var connectedSourceRow: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(sourceAccent.opacity(0.10))
                            .frame(width: 34, height: 34)
                        Image(systemName: sourceIcon)
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(sourceAccent.opacity(0.85))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Connected app")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.white.opacity(0.80))
                        Text(externalConnectionName)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(Color(red: 0.30, green: 0.78, blue: 0.45))
                    }
                }

                Spacer()

                Button {
                    if activeSource == .appleHealth && isAppleHealthConnected {
                        showDisconnectAppleHealthConfirmation = true
                    } else if isStravaConnected {
                        showDisconnectStravaConfirmation = true
                    }
                } label: {
                    Text("Disconnect")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(sourceAccent.opacity(0.80))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(cardBackground)

            Button {
                showConnectProvidersSheet = true
            } label: {
                HStack {
                    Text("Switch source")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.44))
                    Spacer()
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.25))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.02))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                    }
            )
        }
    }

    private var sourceAccent: Color {
        if activeSource == .appleHealth && isAppleHealthConnected {
            return Color(red: 1.0, green: 0.28, blue: 0.28)
        }
        return Color(red: 0.99, green: 0.32, blue: 0.14)
    }

    private var sourceIcon: String {
        if activeSource == .appleHealth && isAppleHealthConnected { return "heart.fill" }
        return "figure.run"
    }

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("NOTIFICATIONS", icon: "bell.fill")

            if NotificationService.shared.isAuthorized {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Push Notifications")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.white.opacity(0.80))
                        Text("Enabled")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(Color(red: 0.30, green: 0.78, blue: 0.45))
                    }
                    Spacer()
                    Circle()
                        .fill(Color(red: 0.30, green: 0.78, blue: 0.45))
                        .frame(width: 8, height: 8)
                }
                .padding(16)
                .background(cardBackground)
            } else {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Push Notifications")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color.white.opacity(0.80))
                            Text("Tap to enable in Settings")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.white.opacity(0.36))
                        }
                        Spacer()
                        Image(systemName: "arrow.up.forward.app")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.white.opacity(0.35))
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background(cardBackground)
            }
        }
        .onAppear {
            Task { await NotificationService.shared.refreshAuthorizationStatus() }
        }
    }

    private var rateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("RATE THE APP", icon: "star.fill")

            Button {
                if let url = URL(string: "https://apps.apple.com/app/id6744878508?action=write-review") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Text("Rate on the App Store")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.80))
                    Spacer()
                    Image(systemName: "star")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.white.opacity(0.35))
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(cardBackground)
        }
    }

    private var instagramSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("COMMUNITY", icon: "person.2.fill")

            Button {
                if let url = URL(string: "https://www.instagram.com/selfshare__") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Text("Follow on Instagram")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.80))
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.35))
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
            isStravaConnected: false,
            isAppleHealthConnected: false,
            activeSource: .strava,
            isConnecting: false,
            onDisconnectStrava: {},
            onConnectStrava: {},
            onDisconnectAppleHealth: {},
            onConnectAppleHealth: {},
            onSignOut: {}
        )
    }
    .preferredColorScheme(.dark)
}

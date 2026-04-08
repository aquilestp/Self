import SwiftUI

struct ContentView: View {
    @State private var authViewModel = AuthViewModel()
    @AppStorage("has_seen_welcome_onboarding") private var hasSeenWelcomeOnboarding: Bool = false

    var body: some View {
        Group {
            if authViewModel.isLoading && !authViewModel.isAuthenticated {
                splashScreen
            } else if authViewModel.isAuthenticated {
                DashboardRootView(authViewModel: authViewModel)
            } else if hasSeenWelcomeOnboarding {
                LoginView(authViewModel: authViewModel, onBack: {
                    withAnimation(.snappy(duration: 0.42, extraBounce: 0.02)) {
                        hasSeenWelcomeOnboarding = false
                    }
                })
            } else {
                WelcomeOnboardingView(
                    onComplete: {
                        withAnimation(.snappy(duration: 0.42, extraBounce: 0.02)) {
                            hasSeenWelcomeOnboarding = true
                        }
                    }
                )
            }
        }
        .tint(.blue)
        .task {
            authViewModel.startAuthListener()
        }
    }

    private var splashScreen: some View {
        VStack {
            Spacer()
            WordmarkView()
            Spacer()
            ProgressView()
                .tint(.white.opacity(0.5))
                .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

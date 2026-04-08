import SwiftUI

struct ContentView: View {
    @State private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isLoading && !authViewModel.isAuthenticated {
                splashScreen
            } else if authViewModel.isAuthenticated {
                DashboardRootView(authViewModel: authViewModel)
            } else {
                LoginView(authViewModel: authViewModel)
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

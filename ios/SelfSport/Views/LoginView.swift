import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Bindable var authViewModel: AuthViewModel

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: max(120, proxy.size.height * 0.34))

                WordmarkView()

                Color.clear
                    .frame(height: max(88, proxy.size.height * 0.14))

                VStack(spacing: 30) {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        Task {
                            await authViewModel.signInWithApple(result)
                        }
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 44)
                    .clipShape(.rect(cornerRadius: 14))

                    Button {
                        Task {
                            await authViewModel.signInWithGoogle()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            GoogleMarkView()

                            if authViewModel.isGoogleLoading {
                                ProgressView()
                                    .tint(.white.opacity(0.44))
                            }

                            Text("Continue with Google")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.88))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                    }
                    .buttonStyle(.plain)
                    .background(.white.opacity(0.08), in: .rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(0.10), lineWidth: 1)
                    }
                }
                .frame(maxWidth: 280)
                .disabled(authViewModel.isLoading)

                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .padding(.top, 20)
                }

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                }

                Text("SHARE YOUR SELF")
                    .font(.footnote.weight(.medium))
                    .tracking(8)
                    .foregroundStyle(.white.opacity(0.34))
                    .padding(.top, 28)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 28)
            .background(.black)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoginView(authViewModel: AuthViewModel())
        .preferredColorScheme(.dark)
}

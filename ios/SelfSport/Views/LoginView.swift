import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Bindable var authViewModel: AuthViewModel
    var onBack: (() -> Void)? = nil
    @State private var showDevLogin: Bool = false
    @State private var devEmail: String = ""
    @State private var devPassword: String = ""

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                if let onBack {
                    HStack {
                        Button {
                            onBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.64))
                                .frame(width: 36, height: 36)
                                .background(.white.opacity(0.08), in: .circle)
                        }
                        Spacer()
                    }
                    .padding(.top, 12)
                }

                Color.clear
                    .frame(height: max(onBack != nil ? 80 : 120, proxy.size.height * (onBack != nil ? 0.24 : 0.34)))

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

                if showDevLogin {
                    VStack(spacing: 12) {
                        TextField("Email", text: $devEmail)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.06), in: .rect(cornerRadius: 8))

                        SecureField("Password", text: $devPassword)
                            .textContentType(.password)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.06), in: .rect(cornerRadius: 8))

                        Button {
                            Task {
                                await authViewModel.signInWithEmail(email: devEmail, password: devPassword)
                            }
                        } label: {
                            Text("Sign In")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        .background(.white.opacity(0.06), in: .rect(cornerRadius: 8))
                        .disabled(devEmail.isEmpty || devPassword.isEmpty)
                    }
                    .frame(maxWidth: 240)
                    .padding(.top, 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer(minLength: 16)

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showDevLogin.toggle()
                    }
                } label: {
                    Text(showDevLogin ? "Hide" : "Developer Access")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.18))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 12)

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

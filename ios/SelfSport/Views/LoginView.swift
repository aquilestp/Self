import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Bindable var authViewModel: AuthViewModel
    var onBack: (() -> Void)? = nil
    @State private var showDevLogin: Bool = false
    @State private var showDevModal: Bool = false
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

                VStack(spacing: 14) {
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

                    Button {
                        Task { await authViewModel.signInWithDemo() }
                    } label: {
                        HStack(spacing: 8) {
                            if authViewModel.isDemoLoading {
                                ProgressView()
                                    .tint(.white.opacity(0.60))
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "play.circle")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.50))
                            }
                            Text("Try Demo")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.60))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                    }
                    .buttonStyle(.plain)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(0.14), lineWidth: 1)
                    }
                    .disabled(authViewModel.isDemoLoading)
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

                Spacer(minLength: 16)

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showDevLogin.toggle()
                    }
                } label: {
                    Text(showDevLogin ? "Hide" : "Developer Access")
                        .font(.caption2)
                        .foregroundStyle(.white)
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
        .onChange(of: showDevLogin) { _, newValue in
            if newValue {
                showDevModal = true
            }
        }
        .sheet(isPresented: $showDevModal, onDismiss: {
            showDevLogin = false
        }) {
            DevLoginModal(authViewModel: authViewModel, devEmail: $devEmail, devPassword: $devPassword, isPresented: $showDevModal)
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

#Preview {
    LoginView(authViewModel: AuthViewModel())
        .preferredColorScheme(.dark)
}

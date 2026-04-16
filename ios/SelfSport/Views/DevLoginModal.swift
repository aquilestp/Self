import SwiftUI

struct DevLoginModal: View {
    @Bindable var authViewModel: AuthViewModel
    @Binding var devEmail: String
    @Binding var devPassword: String
    @Binding var isPresented: Bool
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    @State private var isSigningIn: Bool = false
    @State private var localError: String?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Developer Access")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            TextField("Email", text: $devEmail)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .font(.callout)
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 10))
                .focused($focusedField, equals: .email)

            SecureField("Password", text: $devPassword)
                .textContentType(.password)
                .font(.callout)
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 10))
                .focused($focusedField, equals: .password)

            if let localError {
                Text(localError)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task {
                    isSigningIn = true
                    localError = nil
                    await authViewModel.signInWithEmail(email: devEmail, password: devPassword)
                    if let err = authViewModel.errorMessage {
                        localError = err
                        isSigningIn = false
                    } else {
                        isPresented = false
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if isSigningIn {
                        ProgressView()
                            .tint(.white)
                            .controlSize(.small)
                    }
                    Text("Sign In")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .background(.blue, in: .rect(cornerRadius: 10))
                .contentShape(.rect(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .disabled(devEmail.isEmpty || devPassword.isEmpty || isSigningIn)
            .opacity(devEmail.isEmpty || devPassword.isEmpty ? 0.5 : 1)
        }
        .padding(20)
        .onAppear {
            focusedField = .email
        }
    }
}

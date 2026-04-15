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
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.quaternary, in: .rect(cornerRadius: 10))
                .focused($focusedField, equals: .email)

            SecureField("Password", text: $devPassword)
                .textContentType(.password)
                .font(.callout)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.quaternary, in: .rect(cornerRadius: 10))
                .focused($focusedField, equals: .password)

            Button {
                Task {
                    await authViewModel.signInWithEmail(email: devEmail, password: devPassword)
                    isPresented = false
                }
            } label: {
                Text("Sign In")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .background(.blue, in: .rect(cornerRadius: 10))
            .disabled(devEmail.isEmpty || devPassword.isEmpty)
            .opacity(devEmail.isEmpty || devPassword.isEmpty ? 0.5 : 1)
        }
        .padding(20)
        .onAppear {
            focusedField = .email
        }
    }
}

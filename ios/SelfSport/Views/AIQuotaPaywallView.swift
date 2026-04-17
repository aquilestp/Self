import SwiftUI

struct AIQuotaPaywallView: View {
    let kind: AIGenerationKind
    let daysUntilNextSlot: Int
    let onDismiss: () -> Void

    @State private var appeared: Bool = false
    @State private var showSoonAlert: Bool = false

    private var limitText: String {
        kind == .image ? "10 imágenes" : "2 videos"
    }

    private var resetText: String {
        if daysUntilNextSlot <= 0 {
            return "Tu próxima generación gratis está disponible ahora"
        }
        if daysUntilNextSlot == 1 {
            return "Tu próxima \(kind == .image ? "imagen" : "video") gratis vuelve mañana"
        }
        return "Tu próxima \(kind == .image ? "imagen" : "video") gratis vuelve en \(daysUntilNextSlot) días"
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.06, blue: 0.12), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.1), in: .circle)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer(minLength: 12)

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.35), Color.orange.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .blur(radius: 18)
                        .scaleEffect(appeared ? 1.0 : 0.7)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.white.opacity(0.06)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 96, height: 96)
                        .overlay(
                            Circle().stroke(.white.opacity(0.2), lineWidth: 0.5)
                        )

                    Image(systemName: "crown.fill")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.85, blue: 0.4), Color(red: 0.95, green: 0.6, blue: 0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .symbolEffect(.pulse, options: .repeating, value: appeared)
                }
                .scaleEffect(appeared ? 1.0 : 0.85)
                .opacity(appeared ? 1.0 : 0.0)

                VStack(spacing: 10) {
                    Text("Llegaste a tu límite mensual")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Usaste tus \(limitText) gratis de este mes.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .opacity(appeared ? 1.0 : 0.0)
                .offset(y: appeared ? 0 : 12)

                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.system(size: 12, weight: .semibold))
                    Text(resetText)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(.white.opacity(0.75))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white.opacity(0.08), in: .capsule)
                .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 0.5))
                .padding(.top, 18)
                .opacity(appeared ? 1.0 : 0.0)

                VStack(alignment: .leading, spacing: 14) {
                    benefitRow(icon: "infinity", title: "Generaciones ilimitadas", subtitle: "Imágenes y videos sin tope mensual")
                    benefitRow(icon: "sparkles.tv", title: "Videos en mayor calidad", subtitle: "Resoluciones más altas y mayor duración")
                    benefitRow(icon: "wand.and.stars", title: "Acceso anticipado", subtitle: "Nuevos estilos antes que nadie")
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 0.5)
                )
                .padding(.horizontal, 20)
                .padding(.top, 26)
                .opacity(appeared ? 1.0 : 0.0)
                .offset(y: appeared ? 0 : 16)

                Spacer()

                VStack(spacing: 10) {
                    Button {
                        HapticService.medium.impactOccurred()
                        showSoonAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Upgrade a Pro")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.88, blue: 0.45), Color(red: 0.98, green: 0.7, blue: 0.25)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: .rect(cornerRadius: 14)
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        onDismiss()
                    } label: {
                        Text("Entendido")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .opacity(appeared ? 1.0 : 0.0)
                .offset(y: appeared ? 0 : 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.85)) {
                appeared = true
            }
        }
        .alert("Muy pronto", isPresented: $showSoonAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("El plan Pro estará disponible muy pronto.")
        }
    }

    private func benefitRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(red: 1.0, green: 0.82, blue: 0.4))
                .frame(width: 32, height: 32)
                .background(Color.yellow.opacity(0.12), in: .circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
        }
    }
}

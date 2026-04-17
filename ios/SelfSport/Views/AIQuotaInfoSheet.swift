import SwiftUI

struct AIQuotaInfoSheet: View {
    let kind: AIGenerationKind
    let used: Int
    let limit: Int
    let nextRenewalDate: Date?
    let daysUntilRenewal: Int
    let onDismiss: () -> Void

    private var remaining: Int { max(0, limit - used) }
    private var progress: Double {
        guard limit > 0 else { return 0 }
        return min(1.0, Double(used) / Double(limit))
    }

    private var accent: Color {
        if remaining == 0 { return Color(red: 0.95, green: 0.40, blue: 0.40) }
        if remaining <= (kind == .image ? 3 : 1) { return Color(red: 0.98, green: 0.72, blue: 0.30) }
        return .white
    }

    private var kindLabel: String { kind == .image ? "images" : "videos" }

    private var renewalDateText: String? {
        guard let date = nextRenewalDate else { return nil }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(.white.opacity(0.25))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 18)

            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(accent)
                Text("Your free plan")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 18)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(used)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                    Text("/ \(limit) \(kindLabel) used this cycle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.10))
                        Capsule()
                            .fill(accent.opacity(0.9))
                            .frame(width: max(6, geo.size.width * progress))
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)

            renewalRow
                .padding(.horizontal, 22)
                .padding(.bottom, 18)

            Text("Each \(kind == .image ? "image" : "video") you generate counts for 30 days from its creation date.")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 22)
                .padding(.bottom, 22)

            Button {
                onDismiss()
            } label: {
                Text("Got it")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.white.opacity(0.14))
                    .clipShape(.rect(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 22)
            .padding(.bottom, 22)
        }
        .background(.black.opacity(0.6))
        .background(.ultraThinMaterial)
        .presentationDetents([.height(380)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
    }

    @ViewBuilder
    private var renewalRow: some View {
        HStack(spacing: 12) {
            Image(systemName: renewalIcon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 32, height: 32)
                .background(accent.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(renewalTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
                Text(renewalSubtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white.opacity(0.06), in: .rect(cornerRadius: 14))
    }

    private var renewalIcon: String {
        if used == 0 { return "sparkle" }
        return "calendar"
    }

    private var renewalTitle: String {
        if used == 0 {
            return "Your 30 days start with your first generation"
        }
        if remaining == 0, let dateText = renewalDateText {
            return "Available again on \(dateText)"
        }
        if let dateText = renewalDateText {
            return "Your quota renews on \(dateText)"
        }
        return "Renews 30 days after each generation"
    }

    private var renewalSubtitle: String {
        if used == 0 {
            return "Nothing counts until you generate your first \(kind == .image ? "image" : "video")."
        }
        if daysUntilRenewal <= 0 {
            return "A new slot is available now."
        }
        if daysUntilRenewal == 1 {
            return "Next slot frees up tomorrow."
        }
        return "Next slot frees up in \(daysUntilRenewal) days."
    }
}

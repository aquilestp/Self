import SwiftUI

struct TemplatePickerSheet: View {
    let templates: [ActivityHighlight]
    let onPick: (ActivityHighlight) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(templates) { template in
                        Button {
                            HapticService.medium.impactOccurred()
                            onPick(template)
                        } label: {
                            TemplateRow(template: template)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(white: 0.06))
            .navigationTitle("Pick a template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(white: 0.06), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

private struct TemplateRow: View {
    let template: ActivityHighlight

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(template.accent.opacity(0.14))
                    .frame(width: 46, height: 46)

                Image(systemName: template.systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(template.accent.opacity(0.90))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(template.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.94))

                Text("\(template.distance) · \(template.pace) · \(template.duration)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white.opacity(0.48))
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.30))
        }
        .padding(16)
        .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
}

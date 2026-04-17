import SwiftUI

extension PhotoEditorView {

    var editStyleDrawer: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(.white.opacity(0.35))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 8)

            HStack {
                Text("EDIT STYLE")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(1.2)
                Spacer()
                AIQuotaBadge(
                    kind: .image,
                    used: quotaService.imagesUsed,
                    limit: AIQuotaService.imageLimit
                )
                .padding(.trailing, 6)
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        showEditStyleDrawer = false
                        selectedEditStyle = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.1), in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 14)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(AIEditStyle.allCases) { style in
                        editStyleCard(style: style)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 14)
            }
            .contentMargins(.horizontal, 0)

            if hasCanvasContent && selectedEditStyle != nil {
                HStack(spacing: 10) {
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                    Text("Include stats overlay")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Toggle("", isOn: $includeStatsOverlay)
                        .labelsHidden()
                        .tint(Color.white.opacity(0.6))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 10))
                .padding(.horizontal, 18)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .animation(.easeInOut(duration: 0.25), value: hasCanvasContent)
            }

            Button {
                hapticMedium.impactOccurred()
                if !quotaService.hasImageQuota {
                    quotaPaywallKind = .image
                    showQuotaPaywall = true
                    return
                }
                startAIGeneration()
            } label: {
                Text("Generate")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color.white.opacity(0.28), Color.white.opacity(0.18)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
            .opacity(selectedEditStyle != nil ? 1 : 0)
            .allowsHitTesting(selectedEditStyle != nil)
        }
        .background(.black.opacity(0.55))
        .background(.ultraThinMaterial)
        .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedEditStyle != nil)
    }

    func editStyleCard(style: AIEditStyle) -> some View {
        let isSelected = selectedEditStyle == style
        return Button {
            hapticMedium.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedEditStyle = isSelected ? nil : style
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: style.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white.opacity(isSelected ? 0.95 : 0.55))
                Text(style.rawValue.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(isSelected ? 0.9 : 0.5))
                    .tracking(0.5)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        isSelected
                        ? LinearGradient(colors: [Color.white.opacity(0.20), Color.white.opacity(0.12)], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [Color(red: 0.18, green: 0.13, blue: 0.1), Color(red: 0.12, green: 0.08, blue: 0.06)], startPoint: .top, endPoint: .bottom)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.white.opacity(0.35) : Color.white.opacity(0.08), lineWidth: 0.5)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

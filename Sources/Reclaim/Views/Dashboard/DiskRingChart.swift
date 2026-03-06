import SwiftUI

struct DiskRingChart: View {
    let usage: DiskUsage
    var size: CGFloat = 180

    private var usedFraction: Double { usage.usedFraction }
    private let ringWidth: CGFloat = 18

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.secondary.opacity(0.15), lineWidth: ringWidth)

            // Used ring
            Circle()
                .trim(from: 0, to: usedFraction)
                .stroke(
                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: usedFraction)

            // Centre text
            VStack(spacing: 2) {
                Text("\(Int(usedFraction * 100))%")
                    .font(.system(size: size * 0.18, design: .rounded).weight(.bold))
                Text("used")
                    .font(.system(size: size * 0.09))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}

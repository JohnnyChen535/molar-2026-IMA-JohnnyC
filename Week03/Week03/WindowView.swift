import SwiftUI

struct WindowView: View {
    @State private var pieces = makeGlass()
    @State private var windowNumber = 1

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.09, blue: 0.10)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {

                        Text("Stained Glass")
                            .font(.system(size: 36, weight: .regular, design: .serif))

                    }

                    GlassView(pieces: pieces)
                        .aspectRatio(0.64, contentMode: .fit)
                        .frame(maxWidth: 300)
                        .padding(.horizontal, 24)

                    Text("Ver. \(windowNumber)")
                        .font(.caption)
                        .tracking(2)
                        .foregroundStyle(.secondary)

                    Button {
                        pieces = makeGlass()
                        windowNumber += 1
                    } label: {
                        Label("New Window", systemImage: "arrow.triangle.2.circlepath")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color(red: 0.12, green: 0.11, blue: 0.09))
                    .background(Color(red: 0.88, green: 0.73, blue: 0.46))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .frame(maxWidth: 300)
                    .accessibilityHint("Creates a new arrangement of glass colors and diagonal lines")
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

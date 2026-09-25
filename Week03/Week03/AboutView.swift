import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.09, blue: 0.10)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ABOUT")
                            .font(.caption2)
                            .tracking(3)
                            .foregroundStyle(Color(red: 0.88, green: 0.73, blue: 0.46))

                        Text("Stained Glass")
                            .font(.system(size: 34, weight: .regular, design: .serif))
                    }

                    Text("Inspired by church stained-glass windows with jewel colors, dark outlines, and pointed arch.")
                        .foregroundStyle(.secondary)

                    Divider()

                    VStack(alignment: .leading, spacing: 14) {
                        Text("The palette colors")
                            .font(.title2)
                            .fontDesign(.serif)

                        ForEach(0..<glassColors.count, id: \.self) { index in
                            HStack(spacing: 14) {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(glassColors[index])
                                    .frame(width: 30, height: 30)
                                Text(glassColorNames[index])
                            }
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Refreshing Colors")
                            .font(.title2)
                            .fontDesign(.serif)
                        Text("Each tile divides into two triangles. Their direction and colors change when you tap New Window. The arch outline holds the pattern together.")
                            .foregroundStyle(.secondary)
                        Text("Return to the Window tab to keep exploring.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: 480, alignment: .leading)
                .padding(28)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

//reference [Week08 assignment](https://github.com/molab-itp/content-2026-ima/blob/main/weeks/08_video.md#homework-week08): a video manipulation app with a personal variation.
//reference [08-CameraRecorder](https://github.com/molab-itp/08-CameraRecorder): reference for AVCaptureSession, video-frame callbacks, Core Image processing, and the observable model. This project uses a smaller camera-only version of that approach.
//reference [08-FilterTheWorld](https://github.com/molab-itp/08-FilterTheWorld): class example of filtering live camera video.
//reference [Apple Core Image Filter Reference](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html): CIColorControls saturation and contrast parameters.


import SwiftUI

struct ContentView: View {
    @State private var camera = CameraModel()
    @State private var blackAndWhite = true
    @State private var contrast = 1.0
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                if let frame = camera.frame {
                    Image(decorative: frame, scale: 1)
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel("Live camera preview")
                } else {
                    Text(camera.message)
                        .multilineTextAlignment(.center)
                }
                Spacer()

                Toggle("Black & White", isOn: $blackAndWhite)
                HStack {
                    Text("Contrast")
                    Slider(value: $contrast, in: 0.5...2.0)
                        .accessibilityLabel("Contrast")
                    Text(contrast, format: .number.precision(.fractionLength(1)))
                        .monospacedDigit()
                }
                .disabled(!blackAndWhite)

                if camera.starting {
                    ProgressView()
                } else if camera.frame == nil {
                    Button("Start Camera") { camera.start() }
                }
            }
            .padding()
            .navigationTitle("Black & White")
            .onAppear { camera.start() }
            .onDisappear { camera.stop() }
            .onChange(of: blackAndWhite) { updateFilter() }
            .onChange(of: contrast) { updateFilter() }
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    camera.start()
                } else if scenePhase == .background {
                    camera.stop()
                }
            }
        }
    }

    func updateFilter() {
        camera.setFilter(blackAndWhite: blackAndWhite, contrast: contrast)
    }
}

#Preview {
    ContentView()
}

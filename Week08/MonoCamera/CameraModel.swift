import AVFoundation
import Observation

// Camera setup and frame handling follow the class CameraRecorder example.
@Observable
class CameraModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var frame: CGImage?
    var message = "Starting camera…"
    var starting = false

    @ObservationIgnored private let session = AVCaptureSession()
    @ObservationIgnored private let queue = DispatchQueue(label: "camera")
    @ObservationIgnored private let filter = VideoFilter()
    @ObservationIgnored private var configured = false
    @ObservationIgnored private var blackAndWhite = true
    @ObservationIgnored private var contrast = 1.0
    @ObservationIgnored private var lastFrameTime = -Double.infinity
    @ObservationIgnored private var wantsCamera = false

    func start() {
        wantsCamera = true
        guard !starting else { return }
        starting = true
        message = "Starting camera…"

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            queue.async {
                let error = self.configure()
                if error == nil && !self.session.isRunning {
                    self.session.startRunning()
                }
                DispatchQueue.main.async {
                    self.starting = false
                    if let error { self.message = error }
                }
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { allowed in
                DispatchQueue.main.async {
                    self.starting = false
                    if allowed && self.wantsCamera {
                        self.start()
                    } else if !allowed {
                        self.message = "Allow camera access for MonoCamera in Settings."
                    }
                }
            }
        default:
            message = "Allow camera access for MonoCamera in Settings."
            starting = false
        }
    }

    func stop() {
        wantsCamera = false
        starting = false
        frame = nil
        queue.async {
            self.session.stopRunning()
            self.lastFrameTime = -Double.infinity
        }
    }

    func setFilter(blackAndWhite: Bool, contrast: Double) {
        // Change settings on the same queue that handles video frames.
        queue.async {
            self.blackAndWhite = blackAndWhite
            self.contrast = contrast
        }
    }

    private func configure() -> String? {
        if configured { return nil }
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video, position: .back) else {
            return "Camera unavailable. Run this app on an iPhone."
        }

        session.beginConfiguration()
        defer { session.commitConfiguration() }
        session.sessionPreset = .vga640x480

        do {
            let input = try AVCaptureDeviceInput(device: device)
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            output.alwaysDiscardsLateVideoFrames = true
            output.setSampleBufferDelegate(self, queue: queue)

            guard session.canAddInput(input) else {
                return "Could not open the camera."
            }
            session.addInput(input)
            guard session.canAddOutput(output) else {
                session.removeInput(input)
                return "Could not read video frames."
            }
            session.addOutput(output)

            // This app uses the back camera in portrait orientation.
            if let connection = output.connection(with: .video),
               connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
            configured = true
            return nil
        } catch {
            return "Could not start camera: \(error.localizedDescription)"
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        // Limit preview updates so the controls stay responsive.
        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        guard time - lastFrameTime >= 1.0 / 20.0,
              let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        lastFrameTime = time

        if let image = filter.image(from: buffer, blackAndWhite: blackAndWhite, contrast: contrast) {
            DispatchQueue.main.async {
                if self.wantsCamera { self.frame = image }
            }
        }
    }
}

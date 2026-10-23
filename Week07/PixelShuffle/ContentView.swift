import SwiftUI
import PhotosUI
import Photos
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var photo: PixelImage?
    @State private var preview: Image?
    @State private var exportURL: URL?
    @State private var showingPhotos = false
    @State private var showingFiles = false
    @State private var busy = false
    @State private var message = "Import a photo, or a shuffled PNG to restore."

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                if let preview {
                    preview
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel("Photo preview")
                } else {
                    Text("No photo")
                }
                Spacer()

                if busy {
                    ProgressView("Processing…")
                }
                Text(message)
                HStack {
                    Menu("Import") {
                        Button("Photos") { showingPhotos = true }
                        Button("Files") { showingFiles = true }
                    }
                    Spacer()
                    Button("Shuffle") { process(restore: false) }
                        .disabled(photo == nil)
                    Spacer()
                    Button("Restore") { process(restore: true) }
                        .disabled(photo == nil)
                    Spacer()
                    if let exportURL {
                        ShareLink("Export PNG", item: exportURL)
                    } else {
                        Button("Export PNG") { }
                            .disabled(true)
                    }
                }
                .disabled(busy)
                Button("Save to Photos") { saveToPhotos() }
                    .disabled(busy || exportURL == nil)
            }
            .padding()
            .navigationTitle("Pixel Shuffle")
            .onChange(of: selectedItem) { loadPhoto() }
            .photosPicker(isPresented: $showingPhotos, selection: $selectedItem,
                          matching: .images, preferredItemEncoding: .current)
            .fileImporter(isPresented: $showingFiles, allowedContentTypes: [.image]) { result in
                switch result {
                case .success(let url): loadFile(url)
                case .failure(let error): message = error.localizedDescription
                }
            }
        }
    }

    func loadPhoto() {
        guard let selectedItem else { return }
        busy = true
        Task {
            do {
                guard let data = try await selectedItem.loadTransferable(type: Data.self) else {
                    throw PhotoError.cannotRead
                }
                try await importData(data)
            } catch {
                message = error.localizedDescription
            }
            self.selectedItem = nil
            busy = false
        }
    }

    func loadFile(_ url: URL) {
        busy = true
        Task {
            do {
                let data = try await Task.detached {
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    return try Data(contentsOf: url)
                }.value
                try await importData(data)
            } catch {
                message = error.localizedDescription
            }
            busy = false
        }
    }

    func importData(_ data: Data) async throws {
        // Read pixels away from the interface so large photos do not freeze the buttons.
        let result = try await Task.detached {
            let photo = try PixelImage.load(data)
            let url = try saveForExport(photo)
            return (photo, url)
        }.value
        show(result.0, url: result.1)
        message = "Imported. Keep exported PNGs unchanged for restoration."
    }

    func process(restore: Bool) {
        guard let photo else { return }
        busy = true
        Task {
            do {
                let result = try await Task.detached {
                    let output = photo.moved(restore: restore)
                    let url = try saveForExport(output)
                    return (output, url)
                }.value
                show(result.0, url: result.1)
                message = restore ? "Restoration applied." : "Shuffled. Export as PNG to restore later."
            } catch {
                message = error.localizedDescription
            }
            busy = false
        }
    }

    func saveToPhotos() {
        guard let exportURL else { return }
        busy = true
        Task {
            // Only ask for permission to add photos.
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard status == .authorized else {
                message = "Allow adding photos in Settings to save to Photos."
                busy = false
                return
            }
            do {
                try await PHPhotoLibrary.shared().performChanges {
                    // Save the PNG file without converting it to JPEG.
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .photo, fileURL: exportURL, options: nil)
                }
                message = "Saved PNG to Photos."
            } catch {
                message = "Could not save to Photos: \(error.localizedDescription)"
            }
            busy = false
        }
    }

    func show(_ photo: PixelImage, url: URL) {
        self.photo = photo
        if let image = photo.makeImage() {
            preview = Image(decorative: image, scale: 1)
        }
        exportURL = url
    }
}

// Share an actual PNG file, so the export keeps the pixel values.
func saveForExport(_ photo: PixelImage) throws -> URL {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("PixelShuffle")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let url = directory.appendingPathComponent("PixelShuffle.png")
    try photo.pngData().write(to: url, options: .atomic)
    return url
}

#Preview {
    ContentView()
}

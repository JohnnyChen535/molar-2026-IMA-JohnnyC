# Pixel Shuffle

Import a photo, move its pixels, and export a PNG. Import that PNG again to restore it with the same rule. The app does not need a stored copy of the original.

## How it works

Each row moves sideways by an amount calculated from its row number. Each column then moves vertically by an amount calculated from its column number. The remainder operator `%` wraps positions at the image edges. This happens three times.

Restore moves columns in the opposite direction first, then rows, three times. Every move is reversible, and no two pixels are assigned to the same position. There is no random seed or password.

## Use

1. Import an image from Photos or Files.
2. Tap Shuffle once.
3. Tap Save to Photos and allow adding photos, or use Export PNG and Save to Files.
4. Close the app if desired. Import the saved PNG from Photos or Files.
5. Tap Restore once, then export the result if desired.

Tapping Shuffle twice requires tapping Restore twice. The app cannot tell whether an arbitrary imported image is shuffled.

Save to Photos saves the image currently displayed as a new PNG, including shuffled or restored images. It requests add-only photo permission. If permission is denied, enable adding photos for PixelShuffle in Settings and try again.

Keep exported files unchanged. JPEG conversion, resizing, cropping, screenshots, and messaging services that recompress images can prevent exact restoration.

The app restores the pixel arrangement of its imported image, not the original file's metadata or file bytes. Import uses 8-bit sRGB, applies photo orientation, and puts transparent pixels on a white background. The photo's dimensions are preserved. Images over 25 megapixels are rejected instead of being silently resized. Live Photos and animated images use a single still image.

## References

- [Week07](https://github.com/molab-itp/content-2026-ima/blob/main/weeks/07_photo.md): photo access or manipulation with a personal variation.
- [07-Instafilter ContentView](https://github.com/molab-itp/07-Instafilter/blob/main/project13/Instafilter/ContentView.swift): PhotosPicker, loadTransferable, Task, image preview, and ShareLink. This project shares a PNG file URL instead of a SwiftUI Image.
- [CGContext](https://developer.apple.com/documentation/coregraphics/cgcontext): additional study for reading image pixels into an array.
- [CGImage](https://developer.apple.com/documentation/coregraphics/cgimage): additional study for making an image from the changed pixels.
- [Image I/O](https://developer.apple.com/documentation/imageio): additional study for orientation, image decoding, and lossless PNG export.
- [fileImporter](https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:oncompletion:)): importing the exported PNG from Files.
- [Task](https://developer.apple.com/documentation/swift/task): detached work keeps pixel processing off the interface thread.
- [PHAssetCreationRequest](https://developer.apple.com/documentation/photos/phassetcreationrequest): supplementary PhotoKit study. Save to Photos uses add-only authorization and adds the PNG file inside a photo library change block.

The pixel access, file import, photo saving, and background processing are supplementary material. The movement rule is written with arrays, integer arithmetic, and loops. PixelImage.swift contains the pixel work; ContentView.swift contains the controls.

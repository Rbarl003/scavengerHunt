import Foundation
import UIKit

final class TaskStore {
    static let shared = TaskStore()

    private let fileName = "tasks.json"

    private init() {}

    private var fileURL: URL {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(fileName)
    }

    func load() -> [Task] {
        let url = fileURL
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([Task].self, from: data)
        } catch {
            print("TaskStore load error:", error)
            return []
        }
    }

    func save(_ tasks: [Task]) {
        let url = fileURL
        do {
            // Ensure images directory exists
            let imagesDir = Task.imagesDirectory
            try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)

            // Prepare tasks for encoding: write any inline imageData to files and clear imageData
            var tasksToSave = tasks
            for i in 0..<tasksToSave.count {
                var t = tasksToSave[i]
                if let data = t.imageData {
                    // Compress image before saving
                    if let originalImage = UIImage(data: data) {
                        let compressedData = compressImage(originalImage)
                        
                        // Write file named by task id
                        let filename = "\(t.id.uuidString).jpg"
                        let fileURL = imagesDir.appendingPathComponent(filename)
                        do {
                            try compressedData.write(to: fileURL, options: [.atomic])
                            t.imageFilename = filename
                            t.imageData = nil // Clear to save memory
                            print("Saved image: \(filename) (\(compressedData.count / 1024) KB)")
                        } catch {
                            print("Failed to write image for task \(t.id): \(error)")
                        }
                    }
                } else {
                    // Ensure imageData is always nil for saved tasks
                    t.imageData = nil
                }
                tasksToSave[i] = t
            }

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(tasksToSave)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("TaskStore save error:", error)
        }
    }
    
    // Compress image to reasonable size for mobile device
    private func compressImage(_ image: UIImage) -> Data {
        // First, downsample to max 1920x1920 to reduce memory
        let maxDimension: CGFloat = 1920
        var newImage = image
        
        if image.size.width > maxDimension || image.size.height > maxDimension {
            let scale = maxDimension / max(image.size.width, image.size.height)
            let newSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )
            
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1.0 // Use 1x scale for smaller file size
            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
            newImage = renderer.image { context in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
        }
        
        // Then compress with moderate quality (0.6 = good balance)
        return newImage.jpegData(compressionQuality: 0.6) ?? Data()
    }
}

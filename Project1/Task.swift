import Foundation
import CoreLocation
import UIKit

struct Task: Identifiable, Codable {
    struct Coordinate: Codable {
        let latitude: Double
        let longitude: Double
    }

    let id: UUID
    var title: String
    var details: String
    var completed: Bool
    // Optional image data attached to the task (transient) or filename
    // imageData is used while the image is freshly attached; TaskStore.save will write it to disk
    var imageData: Data?
    // If saved to disk, imageFilename stores the filename under the images directory
    var imageFilename: String?
    // Optional coordinate extracted from the attached photo
    var coordinate: Coordinate?

    init(title: String, details: String) {
        self.id = UUID()
        self.title = title
        self.details = details
        self.completed = false
        self.imageData = nil
        self.imageFilename = nil
        self.coordinate = nil
    }

    // Convenience to get CLLocationCoordinate2D when needed
    func clLocationCoordinate2D() -> CLLocationCoordinate2D? {
        guard let c = coordinate else { return nil }
        return CLLocationCoordinate2D(latitude: c.latitude, longitude: c.longitude)
    }

    // Directory where images are stored
    static var imagesDirectory: URL {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesDir = docs.appendingPathComponent("images", isDirectory: true)
        return imagesDir
    }

    // Convenience to get a UIImage for this task (from memory or disk)
    // Uses ImageCache to avoid repeated disk reads and memory bloat
    func uiImage() -> UIImage? {
        let cacheKey = id.uuidString
        
        // Check cache first
        if let cached = ImageCache.shared.image(forKey: cacheKey) {
            return cached
        }
        
        // Try imageData (freshly attached images)
        if let d = imageData, let image = UIImage(data: d) {
            ImageCache.shared.setImage(image, forKey: cacheKey)
            return image
        }
        
        // Fall back to reading from disk
        if let fname = imageFilename {
            let url = Task.imagesDirectory.appendingPathComponent(fname)
            if let image = UIImage(contentsOfFile: url.path) {
                ImageCache.shared.setImage(image, forKey: cacheKey)
                return image
            }
        }
        
        return nil
    }
    
    // Get a downsampled thumbnail for memory efficiency (e.g., for map annotations)
    func thumbnailImage(maxSize: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
        let thumbCacheKey = "\(id.uuidString)_thumb"
        
        // Check cache first
        if let cached = ImageCache.shared.image(forKey: thumbCacheKey) {
            return cached
        }
        
        // Get full image and downsample
        guard let fullImage = uiImage() else { return nil }
        
        let thumb = downsample(image: fullImage, to: maxSize)
        ImageCache.shared.setImage(thumb, forKey: thumbCacheKey)
        return thumb
    }
    
    private func downsample(image: UIImage, to pointSize: CGSize) -> UIImage {
        let scale = UIScreen.main.scale
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        
        // Calculate aspect-fit size
        let aspectWidth = pointSize.width / image.size.width
        let aspectHeight = pointSize.height / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        let newSize = CGSize(
            width: image.size.width * aspectRatio,
            height: image.size.height * aspectRatio
        )
        
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    // Helper to clear transient image data after saving
    mutating func clearTransientImageData() {
        imageData = nil
    }
}

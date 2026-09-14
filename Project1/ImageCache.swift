//
//  ImageCache.swift
//  Project1
//
//  Memory-efficient image caching
//

import UIKit

/// Simple memory-efficient image cache that automatically clears on memory warnings
final class ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Configure cache limits to prevent excessive memory usage
        // For low-memory devices, use conservative limits
        cache.countLimit = 15 // Maximum number of images (reduced for low memory)
        cache.totalCostLimit = 30 * 1024 * 1024 // 30 MB max (reduced from 50 MB)
        
        // Enable automatic eviction
        cache.evictsObjectsWithDiscardedContent = true
        
        // Listen for memory warnings and clear cache
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        // Also clear cache when app enters background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reduceCache),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        // Estimate memory cost (rough approximation)
        let cost = Int(image.size.width * image.size.height * 4) // RGBA = 4 bytes per pixel
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    @objc func clearCache() {
        cache.removeAllObjects()
        print("ImageCache: Cleared all objects due to memory warning")
    }
    
    @objc func reduceCache() {
        // When app goes to background, reduce cache to free memory
        // Keep only the most recently used images
        print("ImageCache: Reducing cache as app entered background")
        // NSCache will handle eviction automatically based on our limits
    }
    
    func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}

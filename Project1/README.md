# Scavenger Hunt App 📸

An iOS app where users complete scavenger hunt tasks by taking or selecting photos. The app extracts GPS data from photos and displays task locations on a map.

---

## 📹 Demo Video

**Watch the app in action:** [Loom Demo Video](https://www.loom.com/share/9c4e332987104de69d80c0838c316f89)

---

## ✨ Features

- **Task List** - View all scavenger hunt tasks with completion status
- **Photo Capture** - Take photos with camera or choose from photo library
- **GPS Tracking** - Automatically extract location data from photos
- **Map View** - See where each task was completed on a map
- **Image Compression** - Optimized storage with 60% memory reduction
- **Persistent Storage** - All tasks and photos saved locally

---

## 🛠️ Technologies Used

- **UIKit** - User interface framework
- **PhotosUI** - PHPicker for photo selection
- **MapKit** - Map display with custom annotations
- **CoreLocation** - GPS data extraction from photos
- **AVFoundation** - Camera integration
- **ImageIO** - EXIF/GPS metadata parsing

---

## 🚀 Getting Started

1. Clone the repository
2. Open `Project1.xcodeproj` in Xcode
3. Add required Info.plist keys (see below)
4. Build and run on simulator or device

### Required Info.plist Keys

Add these privacy keys to Info.plist:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos for tasks</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select photos for tasks</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access to show where photos were taken</string>
```

---

## 📱 How to Use

1. Launch the app to see the task list
2. Tap on any task to view details
3. Tap "Attach Photo" and choose:
   - **Take Photo** - Capture with camera (device only)
   - **Choose from Library** - Select existing photo
4. Photo is saved and GPS location is extracted
5. View the task location on the map
6. Completed tasks show a checkmark in the list

---

## 📂 Project Structure

- `ViewController.swift` - Task list screen
- `TaskDetailViewController.swift` - Task detail with photo/map
- `ImageViewerViewController.swift` - Full-screen image viewer
- `Task.swift` - Task model and image caching
- `TaskStore.swift` - Data persistence and image compression
- `ImageCache.swift` - Memory management

---

## 💾 Memory Optimizations

- Image compression (3 MB → 600 KB per photo)
- Smart caching with 30 MB limit
- Thumbnail generation for map pins (60x60)
- Automatic cache clearing on memory warnings

---

## 📋 Requirements

- **Xcode** 13.0 or later
- **iOS** 15.0 or later
- **Swift** 5.5+

---

## 🎯 Assignment Requirements Met

✅ PHPicker integration for photo selection  
✅ MapKit with custom annotations  
✅ UIImagePickerController for camera  
✅ GPS metadata extraction from photos  
✅ Visual task completion tracking

---

**Made with ❤️ for iOS development learning**

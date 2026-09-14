# Project Requirements Checklist

## 🎯 Goals

- [x] Use PHPicker to select photos and get photo data from the photo library
- [x] Use MapKit to display custom annotations on a map

## ✅ Required Features

### Task List Screen
- [x] Users can view a list of tasks to be completed
- [x] Hardcoded Task data models created
- [x] Users can tap into a task and navigate to task detail screen
- [x] Tasks that have been completed are visually distinguished (checkmark ✅)
- [x] Completed indicator visible in the task list

### Task Detail Screen
- [x] Users can view the title, description, and attached photo of the task
- [x] Users can attach a photo to the task
- [x] Attaching a photo marks the task as completed with visual indicator
- [x] Shows the location of the photo inside the map
- [x] After completing the task on detail view, the list page reflects it was completed

## 🌟 Stretch Features

- [x] Give the user the option to open camera instead of choosing from photo library
  - [x] Uses UIImagePickerController for camera
  - [x] Uses PHPicker for photo library (PHPicker recommended over UIImagePickerController)
  - [x] Action sheet to choose between camera and library

## 💾 Memory Optimizations (Critical for Low Memory Devices)

- [x] ImageCache system with automatic memory management
- [x] Image compression before saving (max 1920x1920, 0.6 quality)
- [x] Thumbnail generation for map annotations
- [x] Lazy loading from disk
- [x] Memory warning handlers
- [x] imageData cleared after saving to disk

## 🔐 Required Info.plist Keys

Add these to your Info.plist:

- [ ] `NSCameraUsageDescription`
- [ ] `NSPhotoLibraryUsageDescription` 
- [ ] `NSLocationWhenInUseUsageDescription`

See INFO_PLIST_REQUIREMENTS.md for details.

## 📱 Testing Checklist

- [ ] Build succeeds without memory errors
- [ ] Task list displays correctly
- [ ] Tapping a task navigates to detail screen
- [ ] "Attach Photo" button shows action sheet
- [ ] Camera option works (requires physical device)
- [ ] Photo library picker works
- [ ] Selected photo displays in detail view
- [ ] Task marked as completed after photo attached
- [ ] Map shows location if photo has GPS metadata
- [ ] Map annotation shows thumbnail
- [ ] Checkmark appears in task list for completed tasks
- [ ] App handles memory warnings gracefully

## 🐛 Common Issues & Solutions

### Build Memory Issues
See MEMORY_OPTIMIZATION_GUIDE.md

### Camera Not Working
1. Check Info.plist has NSCameraUsageDescription
2. Must test on physical device (simulator has no camera)
3. Grant camera permission when prompted

### No Location on Photo
1. Photo must have GPS metadata embedded
2. Check Info.plist has NSLocationWhenInUseUsageDescription
3. Grant location permission when taking photo
4. Simulator photos: manually drag photos with GPS data

### Map Not Showing Location
1. Photo must have GPS EXIF data
2. Check that coordinate is extracted correctly
3. Photos from simulator often don't have GPS data

## 📖 Code Structure

```
Project1/
├── AppDelegate.swift          - App lifecycle
├── SceneDelegate.swift        - Scene management
├── Models/
│   └── Task.swift            - Task data model with image caching
├── Views/
│   ├── ViewController.swift           - Task list screen
│   ├── TaskDetailViewController.swift - Task detail & photo attachment
│   └── ImageViewerViewController.swift - Full-screen image viewer
├── Storage/
│   ├── TaskStore.swift       - Persistence & image compression
│   └── ImageCache.swift      - Memory-efficient image caching
└── Info.plist                - Privacy permissions
```

## 🎨 UI Features Implemented

- Task list with checkmark indicators
- Task detail with title, description, image, and map
- Image viewer with zoom capability
- Action sheet for camera/library selection
- Map with custom annotations and thumbnails
- Clean, system-standard iOS design

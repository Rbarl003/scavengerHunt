# Memory Optimization Guide for Project1

## ⚠️ Memory Issues During Build

If you're experiencing "not enough memory to build" errors, try these solutions:

### 1. Xcode Build Settings

#### Clean Build Folder
- Press `Shift + Command + K`
- Or: Product → Clean Build Folder

#### Delete Derived Data
1. Xcode → Settings → Locations
2. Click the arrow next to "Derived Data" path
3. Delete the `Project1-xxxxx` folder
4. Restart Xcode

#### Optimize Build Settings (in Project Settings → Build Settings)
- **Optimization Level (Debug)**: `-Onone`
- **Compilation Mode**: `Incremental`
- **Debug Information Format**: `DWARF` (not DWARF with dSYM for Debug)
- **Build Active Architecture Only (Debug)**: `Yes`

#### Reduce Parallel Build Tasks
1. Xcode → Settings → Locations
2. Click "Advanced" next to Derived Data
3. Reduce "Parallel Build Tasks" to 4 or less

### 2. Simulator vs Device

If building for Simulator uses too much memory:
- Try building for a physical device instead
- Or reduce the simulator's allocated memory

### 3. Close Other Apps
- Close unnecessary apps and browser tabs
- Restart your Mac to free up system memory

## 🚀 Runtime Memory Optimizations (Already Implemented)

### ImageCache System
- Images are cached in memory with limits (50 MB max, 20 images)
- Automatic cache clearing on memory warnings
- Prevents redundant disk reads

### Image Compression
- Images are downsampled to max 1920x1920 before saving
- JPEG compression at 0.6 quality (good balance)
- Thumbnails generated for map annotations (60x60)

### Lazy Loading
- Images loaded from disk only when needed
- Cached after first load
- imageData cleared immediately after saving

### Memory Warning Handling
- TaskDetailViewController clears images on memory warning
- ImageCache automatically clears on memory warning

## 📊 Expected Memory Usage

With these optimizations:
- **Camera photo**: ~3-5 MB (uncompressed in memory)
- **Saved to disk**: ~300-800 KB (compressed JPEG)
- **Cached in memory**: ~300-800 KB per image
- **Thumbnails**: ~10-20 KB each

## 🔍 Testing Memory Efficiency

### In Simulator
1. Run the app
2. Debug → Simulate Memory Warning
3. Check that images reload correctly

### On Device
1. Use Xcode Instruments → Allocations
2. Monitor memory usage while adding photos
3. Should stay under 100 MB for typical usage

## ✅ Checklist

- [x] ImageCache implemented with limits
- [x] Images compressed before saving
- [x] Thumbnails used for map annotations
- [x] imageData cleared after saving
- [x] Memory warning handlers implemented
- [x] Build settings optimized for low memory

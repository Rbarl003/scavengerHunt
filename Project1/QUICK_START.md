# Quick Start Guide - Building with Low Memory

## 🆘 Can't Build Due to Memory Issues?

### Try These Steps IN ORDER:

#### 1. Clean Everything (Do This First!)
```bash
# In Xcode:
1. Press Shift + Command + K (Clean Build Folder)
2. Wait for it to complete
3. Quit Xcode completely
```

#### 2. Delete Derived Data
```bash
# Option A - Through Xcode:
1. Xcode → Settings (Cmd + ,)
2. Locations tab
3. Click arrow next to "Derived Data"
4. Find and delete "Project1-xxxxx" folder

# Option B - Terminal:
rm -rf ~/Library/Developer/Xcode/DerivedData/Project1-*
```

#### 3. Free Up System Memory
```bash
# Close these before building:
- Chrome/Safari (all tabs)
- Slack, Discord, etc.
- Other Xcode projects
- Heavy apps (Photoshop, Final Cut, etc.)

# Then restart your Mac
```

#### 4. Optimize Build Settings
```
Project Navigator → Click "Project1" → Build Settings tab → Search for:

1. "Optimization Level"
   - Debug: -Onone (No Optimization)

2. "Compilation Mode"  
   - Debug: Incremental

3. "Build Active Architecture Only"
   - Debug: Yes

4. "Debug Information Format"
   - Debug: DWARF (NOT "DWARF with dSYM")
```

#### 5. Reduce Xcode Build Parallelism
```
Xcode → Settings → Locations → Advanced button
Set "Parallel Build Tasks" to: 4 (or less)
```

#### 6. Build for Device Instead of Simulator
```
If you have a physical iPhone/iPad:
1. Connect device
2. Select it in the device dropdown
3. Build (Cmd + B)

Device builds often use less memory than simulator builds
```

#### 7. Build Only What You Need
```
Product → Scheme → Edit Scheme → Build
Uncheck "Find Implicit Dependencies" temporarily
```

## ✅ If Build Succeeds

### Add Info.plist Keys Before Running!
```xml
Open Info.plist and add:

<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos for your tasks.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to attach photos to your tasks.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses your location to tag photos with where they were taken.</string>
```

### Testing Checklist:
- [ ] App launches
- [ ] Task list displays 3 tasks
- [ ] Tap a task → detail screen shows
- [ ] "Attach Photo" → action sheet shows
- [ ] "Choose from Library" → picker shows
- [ ] Select photo → displays in detail view
- [ ] Checkmark appears in task list
- [ ] Map shows location (if photo has GPS)

## 🎯 Expected Memory Usage

### Build Time:
- Peak memory: 2-4 GB (with optimizations)
- Build time: 30-60 seconds (first build)
- Incremental builds: 5-10 seconds

### Runtime:
- App startup: ~50 MB
- After loading 5 photos: ~80-100 MB
- Cache limit: 30 MB max
- Per compressed photo on disk: ~300-800 KB

## 🔍 Verify Memory Optimizations Are Working

### Check ImageCache:
```swift
// Look for these console logs:
"Saved image: xxxxx.jpg (450 KB)" // From TaskStore
"ImageCache: Cleared all objects due to memory warning" // When memory warning received
```

### Test Memory Warnings:
```
While running in simulator:
Debug → Simulate Memory Warning

Expected result: Images clear but reload when needed
```

## 📊 Memory Comparison

### Before Optimizations:
- Full resolution photo: ~3-5 MB
- 5 photos in memory: ~15-25 MB
- No compression: Same size on disk

### After Optimizations:
- Compressed photo on disk: ~300-800 KB
- Cached in memory: Same size
- Thumbnails: ~10-20 KB
- Total for 5 photos: ~2-4 MB on disk, ~30 MB max in cache

## 🚨 Still Can't Build?

### System Requirements:
- macOS: Latest version recommended
- RAM: 8 GB minimum (16 GB recommended)
- Free disk space: 10+ GB

### Last Resort Options:

#### Option 1: Build via Command Line
```bash
cd /path/to/Project1
xcodebuild -scheme Project1 -destination 'platform=iOS Simulator,name=iPhone 15' clean build
```

#### Option 2: Disable Build Optimizations Temporarily
```
Build Settings → Optimization Level
Change ALL to -Onone (including Release)
```

#### Option 3: Reduce Target iOS Version
```
Project Settings → General → Deployment Info
Change to iOS 16.0 (lower = less memory during build)
```

#### Option 4: Close Xcode, Restart Mac
```bash
# Sometimes the simplest solution works
1. Save your work
2. Quit Xcode
3. Restart Mac
4. Open project fresh
5. Clean & Build
```

## 📞 Need More Help?

Check these files in your project:
- `PROJECT_SUMMARY.md` - Complete overview
- `MEMORY_OPTIMIZATION_GUIDE.md` - Detailed memory guide
- `REQUIREMENTS_CHECKLIST.md` - Verify all features
- `INFO_PLIST_REQUIREMENTS.md` - Privacy permissions

---

**Quick Command Reference:**
```bash
# Clean in Xcode
Shift + Cmd + K

# Build in Xcode  
Cmd + B

# Run in Xcode
Cmd + R

# Stop running app
Cmd + .

# Delete Derived Data (Terminal)
rm -rf ~/Library/Developer/Xcode/DerivedData/Project1-*
```

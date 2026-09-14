# 🚨 QUICK FIX: Add These 3 Keys to Info.plist NOW!

## Without these keys, your app WILL CRASH! ⚠️

---

## 📋 Copy & Paste This

### Method 1: Info Tab (Easiest)

1. Click **Project1** target → **Info** tab
2. Click **"+"** button three times and add:

```
Key: Privacy - Camera Usage Description
Value: This app needs camera access to take photos for your tasks.

Key: Privacy - Photo Library Usage Description
Value: This app needs photo library access to attach photos to your tasks.

Key: Privacy - Location When In Use Usage Description
Value: This app uses your location to tag photos with where they were taken.
```

### Method 2: Source Code (Faster)

1. Find **Info.plist** → Right-click → **Open As Source Code**
2. Paste these lines after `<dict>`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos for your tasks.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to attach photos to your tasks.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses your location to tag photos with where they were taken.</string>
```

---

## ✅ Done? Test It!

1. **Clean**: `Shift + Cmd + K`
2. **Build**: `Cmd + B`
3. **Run**: `Cmd + R`
4. **Test**: Tap a task → "Attach Photo" → Should see permission dialog (not crash!)

---

## 📚 Need More Help?

See detailed guides:
- **ADD_INFOPLIST_KEYS.md** - Full instructions
- **VISUAL_INFOPLIST_GUIDE.md** - Step-by-step with screenshots

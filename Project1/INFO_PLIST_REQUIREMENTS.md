# Info.plist Requirements

## Required Privacy Keys

Add these keys to your `Info.plist` file to enable camera and photo library access:

### Camera Access
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos for your tasks.</string>
```

### Photo Library Access
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to attach photos to your tasks.</string>
```

### Location When In Use (for photo metadata)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses your location to tag photos with where they were taken.</string>
```

## How to Add to Info.plist in Xcode

1. Open your project in Xcode
2. Select the target (Project1)
3. Go to the "Info" tab
4. Click the "+" button to add a new row
5. Search for each key above and add the description string

OR

1. Right-click on `Info.plist` in the Project Navigator
2. Choose "Open As" → "Source Code"
3. Add the XML keys above inside the `<dict>` tag

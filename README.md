<h1 align="center">📸 NPImagePicker</h1>

---

## 🚀 Overview

**NPImagePicker** is a Swift Package that provides a simple and customizable interface to pick multiple **images**, **videos**, or **both** using the latest `PHPickerViewController` on iOS.

---

## 🛠 Features

- ✅ Supports image, video, or both media types
- 🔢 Limit or allow unlimited selection
- 🌄 Generates thumbnail image for selected videos
- 🧾 Simple integration and clean API
- 📦 Built using Swift Package Manager
  
---

## ✨ How to Use?

### 1️⃣ Import the Package

```swift
import MultipleImagePicker
```

Add this import to any Swift file where you want to use the picker.

### 2️⃣ Create Required Variables

```
private var picker: NPPickerManager?
private var arrSelectedMedia: [PickedMedia] = []
```

Use these to manage the picker instance and save selected items.

### 3️⃣ Present the Picker
```
self.picker = NPPickerManager(mediaType: .imageVideo, maxSelection: 5)

self.picker?.presentPicker(from: self) { [weak self] pickedItems in
    guard let self = self else { return }
    debugPrint("Selected items: ", pickedItems)
    self.arrSelectedMedia = pickedItems
}
```

- Use .image, .video, or .imageVideo to define the media type.
- Set maxSelection to 0 for unlimited selection.
- The result is an array of PickedMedia objects — easily usable in a collection view or wherever you want.
- For video type, the array will include both a thumbnail image and the video URL.

## 📸 Preview
<p align="center"> <img src="Assets/Preview.gif" alt="MultipleImagePicker Demo" height="450" width="250"> </p>


## 📦 Installation Guide

✅ Add via Swift Package Manager
1. Open your Xcode project.
2. Go to File > Add Packages
3. Enter the package URL:
```
https://github.com/NipunPatel9977/NPImagePicker

```
4. Select the version or branch you'd like to use.

## ⚙️ Requirements

- iOS 14.0+
- Swift 5.5+

## 📝 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 👤 Author

[Nipun Patel](https://github.com/NipunPatel9977)

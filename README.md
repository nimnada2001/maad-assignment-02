# 📱📺 MAAD Assignment 02 – iOS & tvOS Applications
### **Developed by: Nimnada Kirindage**
BSc (Hons) in Information Technology – SLIIT  
Module: **Mobile Application Design & Development**  
Assignment 02 – **Part A (iOS)** + **Part B (tvOS)**  
Repository: https://github.com/nimnada2001/maad-assignment-02.git

---

# ⭐ Overview
This repository contains **two complete applications** developed for the MAAD Assignment 02:

1️⃣ **Scan2Store (iOS)** – An AI-powered object-detection inventory app using **CoreML YOLOv3TinyFP16**.  
2️⃣ **QuizSprintTV (tvOS)** – A 2-player timed trivia quiz game built using **SwiftUI**, custom focus effects, and Apple tvOS HIG.

Both apps are developed individually, follow clean architecture, and fully meet assignment requirements.

---

# 📦 Project List
```
maad-assignment-02/
│
├── Scan2Store-iOS/
│   └── (Source code for Part A – iOS App)
│
└── QuizSprintTV-tvos/
    └── (Source code for Part B – tvOS App)
```

---

# —————————————————————————  
# 📱 **Part A – Scan2Store (iOS App)**  
# —————————————————————————  

## 🔍 Scan2Store – Smart Inventory Scanner for iOS
Scan2Store is an iOS inventory helper that uses **CoreML YOLOv3TinyFP16** object detection to identify items from the camera or imported photos, then save them into a persistent Core Data inventory.

Built entirely with **SwiftUI** and following **Apple’s Human Interface Guidelines (HIG)**.

---

## 🚀 Features

### 🧠 1. Real-time Object Detection
- Uses **YOLOv3TinyFP16.mlmodel** (COCO 80 object classes).  
- Displays bounding boxes + confidence scores.  
- Live camera inference using Vision + throttling.

### 🖼 2. Photo Import Mode
- Import images using **PHPicker**.  
- Runs one-shot detection.  
- Tap any detected object to add it to inventory.

### 📱 3. Three-Screen Navigation (Assignment Requirement)
1. **DetectView** – Live camera + photo detection  
2. **AddEditItemView** – Edit name, quantity, confidence  
3. **InventoryDashboardView** – Search, sort, edit, delete  

### 📦 4. Persistent Storage with Core Data
Stores: detected label, custom name, quantity, confidence, date added, thumbnail.

### 🎨 5. HIG-Compliant UI
NavigationStack, List, Form, Toolbar, searchable, Dynamic Type, Dark Mode.

---

## 🧰 Tech Stack
SwiftUI · CoreML · Vision · AVFoundation · PhotosUI · Core Data

---

## 📁 File Structure
```
Scan2Store-iOS/
├─ Models/
├─ CoreML/
├─ Camera/
├─ Persistence/
├─ Utilities/
└─ Views/
```

---

## ⚙️ Setup Instructions
1. Xcode 15+  
2. iOS 17+  
3. Add **YOLOv3TinyFP16.mlmodel**  
4. Add Info.plist permissions  
5. Run on physical device for best accuracy  

---

# —————————————————————————  
# 📺 **Part B – QuizSprintTV (tvOS App)**  
# —————————————————————————  

## 🎮 QuizSprintTV – A 2-Player Timed Trivia Game for tvOS
A multiplayer trivia game where two players answer **5 random timed questions** each.  
Correct answer → **+10 points**, winner shown at the end.

UI fully optimized for tvOS with custom focus effects, gradient borders, and smooth animations.

---

## 🚀 Features

### 👥 1. Two-Player Quiz Gameplay
- Player name entry  
- 5 unique questions  
- 15-second timer  
- Auto switch between players  

### ⏳ 2. Time Pressure
- SF Symbol timer  
- Timeout auto-submits  

### 🎨 3. Premium tvOS UI
- SF Pro fonts  
- SF Symbols  
- Custom focus engine: gradient border, scale effect, shadow  
- Animated answer cards  

### 🏆 4. Results Screen
- Final scores  
- Winner with crown glow  
- Play Again / Go Home  

---

## 🧠 Architecture
```
QuizSprintTV-tvos/
├─ Models/
├─ ViewModels/
├─ Components/
└─ Views/
```

---

## 🎯 Focus Interaction (HIG)
- `.focusable(true)`  
- `.buttonStyle(.plain)`  
- Gradient border (blue→purple)  
- Smooth animations  
- Parallax-like motion  

---

## 🧪 Testing
Tested on tvOS 17 simulators (1080p + 4K).  
Validated: focus movement, timer, navigation, transitions.

---

# —————————————————————————  
# 🤖 AI-Assisted Development Summary  
# —————————————————————————  
Tools used: **ChatGPT, GitHub Copilot, Cursor AI**.

AI assisted with:
- Architecture guidance  
- UI/UX improvements  
- Debugging suggestions  
- Documentation generation  

**All final implementation, logic, UI structure, and architecture were manually developed by Nimnada Kirindage.**

---

# 👤 Developer
**Nimnada Kirindage**  
BSc (Hons) in Information Technology – SLIIT  
Mobile Application Design & Development  
Assignment 02 (2025)

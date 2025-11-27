📱📺 MAAD Assignment 02 – iOS & tvOS Applications
Developed by: Nimnada Kirindage

BSc (Hons) in Information Technology – SLIIT
Module: Mobile Application Design & Development
Assignment 02 – Part A (iOS) + Part B (tvOS)
Repository: https://github.com/nimnada2001/maad-assignment-02.git

⭐ Overview

This repository contains two complete applications developed for the MAAD Assignment 02:

1️⃣ Scan2Store (iOS) – An AI-powered object-detection inventory app using CoreML YOLOv3TinyFP16.
2️⃣ QuizSprintTV (tvOS) – A 2-player timed trivia quiz game built using SwiftUI, custom focus effects, and Apple tvOS HIG.

Both apps are developed individually, follow clean architecture, and fully meet assignment requirements.

📦 Project List
maad-assignment-02/
│
├── Scan2Store-iOS/
│   └── (Source code for Part A – iOS App)
│
└── QuizSprintTV-tvos/
    └── (Source code for Part B – tvOS App)

—————————————————————————
📱 Part A – Scan2Store (iOS App)
—————————————————————————
🔍 Scan2Store – Smart Inventory Scanner for iOS

Scan2Store is an iOS inventory helper that uses CoreML YOLOv3TinyFP16 object detection to identify items from the camera or imported photos, then save them into a persistent Core Data inventory.

Built entirely with SwiftUI and following Apple’s Human Interface Guidelines (HIG).

🚀 Features
🧠 1. Real-time Object Detection

Uses YOLOv3TinyFP16.mlmodel (COCO 80 object classes).

Displays bounding boxes + confidence scores.

Live camera inference using Vision + throttling.

🖼 2. Photo Import Mode

Import images with PHPicker.

Runs one-shot detection.

Tap any detected object to add it to inventory.

📱 3. Three-Screen Navigation (Assignment Requirement)

DetectView – Live camera + photo detection

AddEditItemView – Edit name, quantity, confidence

InventoryDashboardView – Search, sort, edit, delete

📦 4. Persistent Storage with Core Data

Stores:

Detected label

Custom name

Quantity

Confidence

Date added

Thumbnail image

🎨 5. HIG-Compliant UI

NavigationStack, List, Form, Toolbar

Dynamic Type, Dark Mode

Accessible labels

Smooth minimal animations

🧰 Tech Stack

SwiftUI

CoreML

Vision

AVFoundation

PhotosUI

Core Data

📁 File Structure
Scan2Store-iOS/
├─ Models/
├─ CoreML/
├─ Camera/
├─ Persistence/
├─ Utilities/
└─ Views/

⚙️ Setup Instructions

Xcode 15+

iOS 17+ device or simulator

Add YOLOv3TinyFP16.mlmodel to the project

Add these to Info.plist:

Privacy - Camera Usage Description

Privacy - Photo Library Usage Description

Run on physical device for real camera performance

—————————————————————————
📺 Part B – QuizSprintTV (tvOS App)
—————————————————————————
🎮 QuizSprintTV – A 2-Player Timed Trivia Game for tvOS

QuizSprintTV is a multiplayer trivia game where two players answer 5 random timed questions each.
Correct answers award +10 points and the final UI declares the winner.

Designed for tvOS using SwiftUI, with custom focus animations and fully HIG-compliant navigation.

🚀 Features
👥 1. Two-Player Quiz Gameplay

Player name entry screen

5 unique questions per player

15-second timer per question

Correct → +10 points

Automatic transition between players

⏳ 2. Time Pressure System

SF Symbol timer countdown

Timeout auto-submits the question

🎨 3. Premium tvOS UI / UX

SF Pro typography

SF Symbols (play, timer, crown, house)

Custom focus engine:

Gradient stroke

Scale up (1.06)

Shadow

Parallax-like motion

Custom card components

Smooth transitions

🏆 4. Final Results Screen

Scoreboard

Winner highlighted with crown and glow

Buttons: Play Again, Go Home

🧠 Architecture
QuizSprintTV-tvos/
├─ Models/
├─ ViewModels/
├─ Components/
└─ Views/


Uses clean, scalable MVVM-inspired architecture.

🛠️ tvOS Focus Interaction (HIG Compliant)

.focusable(true) with .onFocusChange

.buttonStyle(.plain) to remove default glow

Gradient border on focus (Blue→Purple, 4pt)

Smooth animations:

withAnimation(.easeOut(duration: 0.2)) { … }

🧪 Testing Notes

Tested on tvOS 17:

Focus movement

Performance on 4K & 1080p simulators

Correct answer handling

Edge cases (timeouts, empty names, etc.)

—————————————————————————
🤖 AI-Assisted Development Summary (Required for Assignment)
—————————————————————————

Both apps were developed using the following AI tools:

🧩 ChatGPT

Helped in architecture planning

UI improvements (HIG compliance)

Code restructuring for SwiftUI and tvOS focus system

README generation and technical documentation

🤖 GitHub Copilot

Auto-suggestions for repetitive SwiftUI elements

Speeding up boilerplate code

Improving ViewModel logic

⚡ Cursor AI

Assisted in UI generation from prompts

Live refactoring inside Xcode workspace

Detected errors + quick fixes

All AI assistance was used for productivity only.
All core logic, UI design, architecture, and implementation were written manually by Nimnada Kirindage.

🧑‍💻 Developer

Nimnada Kirindage
BSc (Hons) in Information Technology – SLIIT
Mobile Application Design & Development
Assignment 02 (2025)

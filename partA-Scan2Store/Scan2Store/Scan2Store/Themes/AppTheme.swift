//
//  AppTheme.swift
//  Scan2Store
//
//  App-wide color theme and styling
//

import SwiftUI

struct AppTheme {
    // Primary brand color - vibrant blue for scanning/tech feel
    static let primaryColor = Color(red: 0.0, green: 0.48, blue: 1.0) // System Blue
    
    // Accent color variations
    static let accentColor = Color.accentColor
    static let successColor = Color.green
    static let warningColor = Color.orange
    static let errorColor = Color.red
    
    // Detection box color - bright, visible blue-green
    static let detectionBoxColor = Color(red: 0.0, green: 0.78, blue: 0.85) // Cyan-teal
    
    // Background colors
    static let backgroundColor = Color(.systemBackground)
    static let secondaryBackgroundColor = Color(.secondarySystemBackground)
    static let groupedBackgroundColor = Color(.systemGroupedBackground)
}

extension Color {
    static let appPrimary = AppTheme.primaryColor
    static let appDetectionBox = AppTheme.detectionBoxColor
}


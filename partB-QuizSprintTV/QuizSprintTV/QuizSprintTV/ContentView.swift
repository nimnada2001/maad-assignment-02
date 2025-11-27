//
//  ContentView.swift
//  QuizSprintTV
//
//  Created by Nimnada Kirindage on 2025-11-27.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(viewModel: viewModel, navigationPath: $navigationPath)
                .navigationDestination(for: String.self) { destination in
                    if destination == "quiz" {
                        QuizView(viewModel: viewModel, navigationPath: $navigationPath)
                    } else if destination == "result" {
                        ResultView(viewModel: viewModel, navigationPath: $navigationPath)
                    }
                }
                .onChange(of: viewModel.gameState.isGameComplete) { _, isComplete in
                    if isComplete {
                        navigationPath.append("result")
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}

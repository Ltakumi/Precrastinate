//
//  ContentView.swift
//  Precrastinate
//
//  Created by Louis Takumi on 2023/11/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            ProcrastinateView()
                .tabItem {
                    Label("Procrastinate", systemImage: "dumbbell.fill")
                }
            
            TasksView()
                .tabItem {
                    Label("Tasks", systemImage: "timer")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "leaf")
                }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

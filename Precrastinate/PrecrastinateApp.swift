//
//  PrecrastinateApp.swift
//  Precrastinate
//
//  Created by Louis Takumi on 2023/11/26.
//

import SwiftUI

@main
struct PrecrastinateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

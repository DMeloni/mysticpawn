//
//  MysticPawnApp.swift
//  MysticPawn
//
//  Created by Denis MELONI on 02/04/2025.
//

import SwiftUI

@main
struct MysticPawnApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

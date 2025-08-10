//
//  AIMeetingAssistantApp.swift
//  AIMeetingAssistant
//
//  Created by Shruti Suryawanshi on 8/9/25.
//

import SwiftUI

@main
struct AIMeetingAssistantApp: App {
    @StateObject private var store = MeetingStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

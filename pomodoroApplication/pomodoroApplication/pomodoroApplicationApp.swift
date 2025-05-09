import SwiftUI

@main
struct pomodoroApplicationApp: App {
    @StateObject private var habitStore = HabitStore()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                HabitListView()
                    .tabItem {
                        Label("Habits", systemImage: "list.bullet")
                    }
                
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.bar")
                    }
            }
            .environmentObject(habitStore)
        }
    }
}

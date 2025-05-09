import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var noteToDelete: UUID?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Today's Stats Card
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Today's Progress")
                            .font(.title2)
                            .bold()
                        
                        HStack(spacing: 20) {
                            StatCard(
                                title: "Total Pomodoros",
                                value: "\(habitStore.todaysTotalPomodoros())",
                                icon: "timer",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Habits Worked On",
                                value: "\(habitStore.todaysHabitsWorkedOn())",
                                icon: "checkmark.circle",
                                color: .green
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    
                    // Notes Summary Card
                    if !habitStore.todaysNotesWithHabits().isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today's Notes")
                                .font(.title2)
                                .bold()
                            
                            ForEach(habitStore.todaysNotesWithHabits(), id: \.habitId) { noteInfo in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(noteInfo.habitTitle)
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            noteToDelete = noteInfo.habitId
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    
                                    Text(noteInfo.note)
                                        .font(.subheadline)
                                        .padding(.vertical, 4)
                                }
                                .padding(.vertical, 4)
                                
                                if noteInfo.habitId != habitStore.todaysNotesWithHabits().last?.habitId {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemGroupedBackground))
            .alert("Delete Note", isPresented: Binding(
                get: { noteToDelete != nil },
                set: { if !$0 { noteToDelete = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let habitId = noteToDelete {
                        habitStore.deleteNote(for: habitId)
                    }
                    noteToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    noteToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this note?")
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

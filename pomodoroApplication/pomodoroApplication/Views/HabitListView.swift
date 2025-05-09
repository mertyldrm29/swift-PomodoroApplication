import SwiftUI

struct HabitListView: View {
    @EnvironmentObject var habitStore: HabitStore
    @State private var showingAddHabit = false
    @State private var newHabitTitle = ""
    @State private var newHabitDescription = ""
    
    var body: some View {
        NavigationView {
            Group {
                if habitStore.habits.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("You don't have any habits.")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Button(action: { showingAddHabit = true }) {
                            Text("Add Your First Habit")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    List {
                        ForEach(habitStore.habits) { habit in
                            NavigationLink(destination: HabitDetailView(habit: habit)) {
                                HabitRowView(habit: habit)
                            }
                        }
                        .onDelete(perform: deleteHabits)
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                NavigationView {
                    Form {
                        TextField("Habit Title", text: $newHabitTitle)
                        TextField("Description (Optional)", text: $newHabitDescription)
                    }
                    .navigationTitle("New Habit")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            showingAddHabit = false
                        },
                        trailing: Button("Add") {
                            let habit = Habit(title: newHabitTitle, description: newHabitDescription)
                            habitStore.addHabit(habit)
                            newHabitTitle = ""
                            newHabitDescription = ""
                            showingAddHabit = false
                        }
                        .disabled(newHabitTitle.isEmpty)
                    )
                }
            }
        }
    }
    
    private func deleteHabits(at offsets: IndexSet) {
        offsets.forEach { index in
            habitStore.deleteHabit(habitStore.habits[index])
        }
    }
}

struct HabitRowView: View {
    let habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(habit.title)
                .font(.headline)
            if !habit.description.isEmpty {
                Text(habit.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text("\(todaysCompletedPomodoros()) Pomodoros today")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func todaysCompletedPomodoros() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return habit.dailyPomodoros.first { Calendar.current.isDate($0.date, inSameDayAs: today) }?.completedSessions ?? 0
    }
}

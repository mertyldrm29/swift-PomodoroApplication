import SwiftUI

struct HabitDetailView: View {
    @EnvironmentObject var habitStore: HabitStore
    let habit: Habit
    @State private var noteText = ""
    
    private var timer: PomodoroTimer? {
        habitStore.getTimer(for: habit)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Timer Section
                VStack {
                    Text(timer?.isWorkSession ?? true ? "Work Time" : "Break Time")
                        .font(.title2)
                        .foregroundColor(timer?.isWorkSession ?? true ? .blue : .green)
                    
                    Text(timer?.formattedTime() ?? "25:00")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            if let timer = timer {
                                if timer.isRunning {
                                    timer.pause()
                                } else {
                                    timer.start()
                                }
                            } else {
                                habitStore.startTimer(for: habit)
                                habitStore.getTimer(for: habit)?.start()
                            }
                        }) {
                            Image(systemName: timer?.isRunning ?? false ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(timer?.isWorkSession ?? true ? .blue : .green)
                        }
                        
                        Button(action: {
                            timer?.skip()
                        }) {
                            Image(systemName: "forward.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                        }
                        
                        if timer != nil {
                            Button(action: {
                                habitStore.stopTimer(for: habit)
                            }) {
                                Image(systemName: "stop.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
                
                // Notes Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's Notes")
                        .font(.headline)
                    
                    TextEditor(text: $noteText)
                        .frame(height: 100)
                        .padding(4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Button(action: saveNote) {
                        Text("Save Note")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
                
                // Progress Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's Progress")
                        .font(.headline)
                    
                    Text("Completed Pomodoros: \(todaysCompletedPomodoros())")
                        .font(.subheadline)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            .padding()
        }
        .navigationTitle(habit.title)
        .onAppear {
            loadTodaysNote()
        }
        .onChange(of: timer?.isWorkSession) { newValue in
            if let newValue = newValue, !newValue { // When work session completes
                habitStore.completePomodoro(for: habit)
            }
        }
        .onReceive(habitStore.objectWillChange) { _ in
            // Force view update when store changes
        }
    }
    
    private func saveNote() {
        habitStore.addNote(noteText, for: habit)
    }
    
    private func loadTodaysNote() {
        let today = Calendar.current.startOfDay(for: Date())
        if let dailyPomodoro = habit.dailyPomodoros.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            noteText = dailyPomodoro.notes
        }
    }
    
    private func todaysCompletedPomodoros() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return habit.dailyPomodoros.first { Calendar.current.isDate($0.date, inSameDayAs: today) }?.completedSessions ?? 0
    }
}

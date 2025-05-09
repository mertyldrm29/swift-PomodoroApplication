import Foundation
import SwiftUI
import Combine

struct HabitNote: Identifiable {
    let habitId: UUID
    let habitTitle: String
    let note: String
    var id: UUID { habitId }
}

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var activeTimers: [UUID: PomodoroTimer] = [:]
    @Published var activeHabitId: UUID?
    
    private let saveKey = "SavedHabits"
    private var timerCancellables: [UUID: AnyCancellable] = [:]
    
    init() {
        loadHabits()
    }
    
    func startTimer(for habit: Habit) {
        if activeTimers[habit.id] == nil {
            let timer = PomodoroTimer()
            activeTimers[habit.id] = timer
            
            // Subscribe to timer changes
            timerCancellables[habit.id] = timer.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        }
    }
    
    func stopTimer(for habit: Habit) {
        timerCancellables[habit.id]?.cancel()
        timerCancellables.removeValue(forKey: habit.id)
        activeTimers[habit.id]?.pause()
        activeTimers.removeValue(forKey: habit.id)
        objectWillChange.send()
    }
    
    func getTimer(for habit: Habit) -> PomodoroTimer? {
        return activeTimers[habit.id]
    }
    
    func completePomodoro(for habit: Habit) {
        var updatedHabit = habit
        let today = Calendar.current.startOfDay(for: Date())
        
        if let index = updatedHabit.dailyPomodoros.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            updatedHabit.dailyPomodoros[index].completedSessions += 1
        } else {
            let newDailyPomodoro = DailyPomodoro(date: today, completedSessions: 1)
            updatedHabit.dailyPomodoros.append(newDailyPomodoro)
        }
        
        updateHabit(updatedHabit)
        objectWillChange.send()
    }
    
    func addNote(_ note: String, for habit: Habit) {
        var updatedHabit = habit
        let today = Calendar.current.startOfDay(for: Date())
        
        if let index = updatedHabit.dailyPomodoros.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            updatedHabit.dailyPomodoros[index].notes = note
        } else {
            let newDailyPomodoro = DailyPomodoro(date: today, notes: note)
            updatedHabit.dailyPomodoros.append(newDailyPomodoro)
        }
        
        updateHabit(updatedHabit)
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
        objectWillChange.send()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
            objectWillChange.send()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
        objectWillChange.send()
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
    
    // Dashboard statistics
    func todaysTotalPomodoros() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return habits.reduce(0) { total, habit in
            total + (habit.dailyPomodoros.first { Calendar.current.isDate($0.date, inSameDayAs: today) }?.completedSessions ?? 0)
        }
    }
    
    func todaysHabitsWorkedOn() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return habits.filter { habit in
            habit.dailyPomodoros.contains { Calendar.current.isDate($0.date, inSameDayAs: today) }
        }.count
    }
    
    func todaysNotesWithHabits() -> [HabitNote] {
        let today = Calendar.current.startOfDay(for: Date())
        return habits.compactMap { habit in
            if let dailyPomodoro = habit.dailyPomodoros.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }),
               !dailyPomodoro.notes.isEmpty {
                return HabitNote(habitId: habit.id, habitTitle: habit.title, note: dailyPomodoro.notes)
            }
            return nil
        }
    }
    
    func todaysNotes() -> [String] {
        let today = Calendar.current.startOfDay(for: Date())
        return habits.compactMap { habit in
            habit.dailyPomodoros.first { Calendar.current.isDate($0.date, inSameDayAs: today) }?.notes
        }.filter { !$0.isEmpty }
    }
    
    func deleteNote(for habitId: UUID) {
        let today = Calendar.current.startOfDay(for: Date())
        if let habitIndex = habits.firstIndex(where: { $0.id == habitId }),
           let pomodoroIndex = habits[habitIndex].dailyPomodoros.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            var updatedHabit = habits[habitIndex]
            updatedHabit.dailyPomodoros[pomodoroIndex].notes = ""
            updateHabit(updatedHabit)
        }
    }
}

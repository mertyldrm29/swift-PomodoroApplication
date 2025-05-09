import Foundation

struct Habit: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String
    var createdAt: Date
    var dailyPomodoros: [DailyPomodoro]
    
    init(id: UUID = UUID(), title: String, description: String = "", createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.dailyPomodoros = []
    }
}

struct DailyPomodoro: Codable {
    var date: Date
    var completedSessions: Int
    var notes: String
    
    init(date: Date = Date(), completedSessions: Int = 0, notes: String = "") {
        self.date = date
        self.completedSessions = completedSessions
        self.notes = notes
    }
}

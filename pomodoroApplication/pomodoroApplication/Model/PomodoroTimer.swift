import Foundation
import Combine

class PomodoroTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval
    @Published var isRunning: Bool = false
    @Published var isWorkSession: Bool = true
    
    private var timer: AnyCancellable?
    private let workDuration: TimeInterval = 25 * 60 // 25 minutes
    private let breakDuration: TimeInterval = 5 * 60  // 5 minutes
    
    init() {
        self.timeRemaining = workDuration
    }
    
    func start() {
        isRunning = true
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.completeSession()
                }
            }
    }
    
    func pause() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func reset() {
        pause()
        timeRemaining = isWorkSession ? workDuration : breakDuration
    }
    
    func skip() {
        completeSession()
    }
    
    private func completeSession() {
        pause()
        isWorkSession.toggle()
        timeRemaining = isWorkSession ? workDuration : breakDuration
        objectWillChange.send()
    }
    
    func formattedTime() -> String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

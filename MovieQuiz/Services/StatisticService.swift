import Foundation

final class StatisticService {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
    }
    
    private var correctAnswers: Int {
        get {
            return storage.integer(forKey: Keys.correct.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
}

extension StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        guard gamesCount > 0 else { return 0.0 }
        
        let totalQuestions = gamesCount * 10
        let accuracy = (Double(correctAnswers) / Double(totalQuestions)) * 100
        
        return accuracy
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: "bestGame.correct")
            let total = storage.integer(forKey: "bestGame.total")
            let date = storage.object(forKey: "bestGame.date") as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: "bestGame.correct")
            storage.set(newValue.total, forKey: "bestGame.total")
            storage.set(newValue.date, forKey: "bestGame.date")
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        correctAnswers += count
        gamesCount += 1
        
        // Создаем новый результат игры
        let newGame = GameResult(correct: count, total: amount, date: Date())
        
        if newGame.isBetterThan(bestGame) {
            bestGame = newGame
        }
    }
    
}

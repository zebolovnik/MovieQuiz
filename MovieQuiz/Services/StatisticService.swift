import Foundation

final class StatisticService {
    
    private let storage: UserDefaults = .standard
    
    // приватное свойства для хранения правильных ответов
    private var correctAnswers: Int {
        get {
            return storage.integer(forKey: "correctAnswers")
        }
        set {
            storage.set(newValue, forKey: "correctAnswers")
        }
    }
    
    // Enum для работы с ключами в UserDefaults
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
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
        // Проверяем, что количество игр не равно нулю
        guard gamesCount > 0 else { return 0.0 }
        
        // Вычисляем среднюю точность
        let totalQuestions = gamesCount * 10
        let accuracy = (Double(correctAnswers) / Double(totalQuestions)) * 100
        
        return accuracy
    }
    
    
    var bestGame: GameResult {
        get {
            // Получаем данные из UserDefaults
            let correct = storage.integer(forKey: "bestGame.correct")
            let total = storage.integer(forKey: "bestGame.total")
            
            // Получаем дату
            let date = storage.object(forKey: "bestGame.date") as? Date ?? Date()
            
            // создаем и возвращаем GameResult с полученными значениями
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            // Записываем данные в UserDefaults
            storage.set(newValue.correct, forKey: "bestGame.correct")
            storage.set(newValue.total, forKey: "bestGame.total")
            storage.set(newValue.date, forKey: "bestGame.date")
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        correctAnswers += count // Обновляем общее количество правильных ответов
        gamesCount += 1 // Увеличиваем количество сыгранных игр
        
        // Создаем новый результат игры
        let newGame = GameResult(correct: count, total: amount, date: Date())
        // Проверяем, если это лучший результат
        if newGame.isBetterThan(bestGame) {
            bestGame = newGame
        }
    }
    
}

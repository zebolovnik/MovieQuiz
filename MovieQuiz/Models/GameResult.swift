import Foundation

struct GameResult {
    let correct: Int // количество правильных ответов
    let total: Int // кол-во вопросов квиза
    let date: Date // дата завершения раунда
    
    // метод сравнения по количеству верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}

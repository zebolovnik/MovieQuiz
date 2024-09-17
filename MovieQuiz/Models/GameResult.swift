import Foundation

struct GameResult: Codable {
    let correct: Int // количество правильных ответов
    let total: Int // кол-во вопросов квиза
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct >= another.correct
    }
}

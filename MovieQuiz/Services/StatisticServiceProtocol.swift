import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var totalAccuracy: Double { get } // средняя точность правильных ответов за все игры в процентах
    var bestGame: GameResult { get }
    
    func store(correct count: Int, total amount: Int)
}

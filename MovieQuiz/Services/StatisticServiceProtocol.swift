import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get } // количество завершённых игр
    var totalAccuracy: Double { get } // средняя точность правильных ответов за все игры в процентах
    var bestGame: GameResult { get } // информация о лучшей попытке
    
    func store(correct count: Int, total amount: Int)
}
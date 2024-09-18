//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikolay Zebolov on 17.09.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    var correctAnswers: Int = 0
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var statisticService: StatisticService?
    var alertPresenter: AlertPresenter?
    var questionFactory: QuestionFactoryProtocol?
    
    // MARK: - Пока так
    
    func yesButtonClicked() {
        answerGived(isYes: true)
    }
    
    func noButtonClicked() {
        answerGived(isYes: false)
    }
    
    func answerGived(isYes: Bool) {
        setButtonsEnabled(false)
        
        guard let currentQuestion = currentQuestion else { return }
        
        // Проверка правильного ответа
        let isCorrect = isYes == currentQuestion.correctAnswer
        
        // Показываем результат ответа через viewController
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }
    
    // Управление состоянием кнопок
    func setButtonsEnabled(_ isEnabled: Bool) {
        viewController?.yesButton.isEnabled = isEnabled
        viewController?.noButton.isEnabled = isEnabled
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.showLoadingIndicator()
        
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.hideLoadingIndicator()
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            guard let statisticService = statisticService else { return }
            
            // Сохраняем результаты игры в статистику
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            
            let bestGame = statisticService.bestGame
            
            let currentResultText = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)"
            let gamesPlayedText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let bestGameText = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
            let averageAccuracyText = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let text = """
            \(currentResultText)
            \(gamesPlayedText)
            \(bestGameText)
            \(averageAccuracyText)
            """
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    self?.restartGame()
                }
            )
            
            if let viewController = viewController {
                alertPresenter?.showAlert(in: viewController, model: alertModel)
            }
        } else {
            self.switchToNextQuestion()
            viewController?.requestNextQuestion()
        }
        self.setButtonsEnabled(true)
    }
    
    func restartGame() {
        resetQuestionIndex()
        correctAnswers = 0
        if let viewController = viewController {
            viewController.requestNextQuestion()
            setButtonsEnabled(true)
        }
    }
    
    // MARK: - Public methods
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    // MARK: - Actions
    

    
}

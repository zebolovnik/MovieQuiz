//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikolay Zebolov on 17.09.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    // MARK: - Пока так
    
    func yesButtonClicked() {
        answerGived(answer: true)
    }
    
    func noButtonClicked() {
        answerGived(answer: false)
    }
    
    func answerGived(answer: Bool) {
        setButtonsEnabled(false)
        
        guard let currentQuestion = currentQuestion else { return }
        
        // Проверка правильного ответа
        let isCorrect = answer == currentQuestion.correctAnswer
        
        // Показываем результат ответа через viewController
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }
    
    // Управление состоянием кнопок
    func setButtonsEnabled(_ isEnabled: Bool) {
        viewController?.yesButton.isEnabled = isEnabled
        viewController?.noButton.isEnabled = isEnabled
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

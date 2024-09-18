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

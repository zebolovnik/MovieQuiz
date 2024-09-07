import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Data Models (модели данных для состояний)
//    private struct QuizStepViewModel {
//        let image: UIImage
//        let question: String
//        let questionNumber: String
//    }
    
//    private struct QuizResultsViewModel {
//        let title: String
//        let text: String
//        let buttonText: String
//    }
    
    //    private struct QuizQuestion {
    //        let image: String
    //        let text: String
    //        let correctAnswer: Bool
    //    }
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0 // Если вам нужно всегда показывать случайный вопрос (через метод requestNextQuestion() из QuestionFactory, и порядок вопросов не важен, то currentQuestionIndex можно убрать.
    private var correctAnswers = 0 // для подсчёта правильных ответов
    
    private let questionAmount: Int = 10 // общее кол-во вопросов для квиза
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory() // экземпляр фабрики вопросов
    private var currentQuestion: QuizQuestion? // вопрос, который видит пользователь
    
    // MARK: - Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nextQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = nextQuestion
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
////        gpt
//        questionFactory = QuestionFactory() // Инициализация фабрики вопросов
//        requestNextQuestion() // Запрашиваем следующий вопрос
        //        guard let currentQuestion = questions[safe: currentQuestionIndex] else {
        //            print("Wow, easy there, our array isn't infinite, you know!")
        //            return
        //        }
//        let viewModel = convert(model: question)
//        show(quiz: viewModel)
        
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setButtonsEnabled(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        setButtonsEnabled(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Методы
    
    private func requestNextQuestion() {
        if let question = questionFactory.requestNextQuestion() {
            currentQuestion = question
            let viewModel = convert(model: question)
            show(quiz: viewModel)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)"
        )
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionAmount - 1 {
//            let text = "Ваш результат: \(correctAnswers)/\(questionAmount)"
            let text = correctAnswers == questionAmount ?
            "Поздравляем, вы ответили на 10 из 10" :
            "Вы ответили на \(correctAnswers) из \(questionAmount), попробуйте еще раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз"
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            // Запрашиваем следующий вопрос через фабрику и сохраняем его в currentQuestion
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion // Сохраняем сгенерированный вопрос
                let viewModel = convert(model: nextQuestion)
                show(quiz: viewModel)
            }
        }
        setButtonsEnabled(true)
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
            self.setButtonsEnabled(true)
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
}

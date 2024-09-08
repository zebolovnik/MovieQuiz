import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0 // Если вам нужно всегда показывать случайный вопрос (через метод requestNextQuestion() из QuestionFactory, и порядок вопросов не важен, то currentQuestionIndex можно убрать.
    private var correctAnswers = 0 // для подсчёта правильных ответов
    
    private let questionAmount: Int = 10 // общее кол-во вопросов для квиза
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory() // экземпляр фабрики вопросов
    private var currentQuestion: QuizQuestion? // вопрос, который видит пользователь
    
    private var alertPresenter: AlertPresenter?
    
    // MARK: - Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        self.alertPresenter = AlertPresenter(viewController: self)
        
        questionFactory.requestNextQuestion()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
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
        questionFactory.requestNextQuestion()
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
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionAmount - 1 {
            let text = correctAnswers == questionAmount ?
            "Поздравляем, вы ответили на 10 из 10" :
            "Вы ответили на \(correctAnswers) из \(questionAmount), попробуйте еще раз!"
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    self?.restartGame()
                }
            )
            
            alertPresenter?.showAlert(with: alertModel)
        } else {
            currentQuestionIndex += 1
            
            questionFactory.requestNextQuestion()
        }
        setButtonsEnabled(true)
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        requestNextQuestion()
        setButtonsEnabled(true)
    }
    
//    private func show(quiz result: QuizResultsViewModel) {
//        let alert = UIAlertController(
//            title: result.title,
//            message: result.text,
//            preferredStyle: .alert)
//        
//        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
//            guard let self = self else { return }
//            self.currentQuestionIndex = 0
//            self.correctAnswers = 0
//            
//            self.questionFactory.requestNextQuestion()
//            
//            self.setButtonsEnabled(true)
//        }
//        
//        alert.addAction(action)
//        
//        self.present(alert, animated: true, completion: nil)
//    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
}

import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionAmount: Int = 10
    
    private var statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    
    // MARK: - Outlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        
        alertPresenter = AlertPresenter(viewController: self)
        
        activityIndicator.hidesWhenStopped = true
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
        // Симуляция ошибки (для тестирования)
        // questionFactory?.simulateError()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        showLoadingIndicator()
        
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            self?.hideLoadingIndicator()
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        answerGived(answer: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        answerGived(answer: false)
    }
    
    // MARK: - Методы
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        // алерт с ошибкой сети
        let alertModel = AlertModel(
            title: "Ошибка сети",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.showAlert(with: alertModel)
    }
    
    
    private func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
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
            guard let statisticService = statisticService else { return }
            
            // Сохраняем результаты игры в статистику
            statisticService.store(correct: correctAnswers, total: questionAmount)
            
            let bestGame = statisticService.bestGame
            let accuracyText = String(format: "%.2f", statisticService.totalAccuracy)
            let currentResultText = "Ваш результат: \(correctAnswers)/\(questionAmount)"
            let gamesPlayedText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let bestGameText = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
            let averageAccuracyText = "Средняя точность: \(accuracyText)%"
            
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
            
            alertPresenter?.showAlert(with: alertModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
        setButtonsEnabled(true)
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        requestNextQuestion()
        setButtonsEnabled(true)
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func answerGived(answer: Bool) {
        setButtonsEnabled(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let isCorrect = answer == currentQuestion.correctAnswer
        
        showAnswerResult(isCorrect: isCorrect)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(message: error.localizedDescription)
    }
    
}

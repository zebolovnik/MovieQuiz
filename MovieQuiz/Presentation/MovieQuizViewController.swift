import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var correctAnswers = 0
    
//    private var currentQuestionIndex = 0
//    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    private var alertPresenter: AlertPresenter?
    private let presenter = MovieQuizPresenter()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        
        alertPresenter = AlertPresenter(viewController: self)
        
        activityIndicator.hidesWhenStopped = true
        
        questionFactory?.loadData()
        showLoadingIndicator()

    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        showLoadingIndicator()
        
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            self?.hideLoadingIndicator()
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        answerGived(answer: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        answerGived(answer: false)
    }
    
    // MARK: - Private functions
    
//    private func convert(model: QuizQuestion) -> QuizStepViewModel {
//        let questionStep = QuizStepViewModel(
//            image: UIImage(data: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
//        )
//        return questionStep
//    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            guard let statisticService = statisticService else { return }
            
            // Сохраняем результаты игры в статистику
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let bestGame = statisticService.bestGame
            
            let currentResultText = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)"
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
            
            alertPresenter?.showAlert(in: self, model: alertModel)
        } else {
            presenter.switchToNextQuestion()
            requestNextQuestion()
        }
        setButtonsEnabled(true)
    }
    
    private func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
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
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.requestNextQuestion()
            }
        )
        
        alertPresenter?.showAlert(in: self, model: alertModel)
    }
    
    private func restartGame() {
        presenter.resetQuestionIndex()
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
        
        guard let currentQuestion = currentQuestion else { return }
        
        let isCorrect = answer == currentQuestion.correctAnswer
        
        showAnswerResult(isCorrect: isCorrect)
    }
    
}

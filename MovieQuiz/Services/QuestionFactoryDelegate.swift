//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Nikolay Zebolov on 08.09.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}

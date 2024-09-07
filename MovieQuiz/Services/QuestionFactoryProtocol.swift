//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Nikolay Zebolov on 07.09.2024.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}

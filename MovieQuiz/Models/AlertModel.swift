//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Nikolay Zebolov on 08.09.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)
}

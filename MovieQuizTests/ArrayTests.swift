//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Nikolay Zebolov on 15.09.2024.
//

import Foundation

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() { // тест на успешное взятие элемента по индексу
        let array = [1, 1, 2, 3, 5]
        
        let value = array[safe: 2]
        
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    
    func testGetValueOutOfRange() throws { // тест на взятие элемента по неправильному индексу
        let array = [1, 1, 2, 3, 5]
        
        let value = array[safe: 20]
        
        XCTAssertNil(value)
    }
}

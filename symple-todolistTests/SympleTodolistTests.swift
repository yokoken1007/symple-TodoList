//
//  symple_todolistTests.swift
//  symple-todolistTests
//
//  Created by 横山　賢一 on 2022/09/07.
//

import XCTest
@testable import symple_todolist

class SympleTodolistTests: XCTestCase {
    let first = FirstViewController()
    
    func testStart() {
        first.start(completion: { score in
            print("Result is \(score)")
        })
    }
}

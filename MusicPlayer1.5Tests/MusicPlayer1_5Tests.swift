//
//  MusicPlayer1_5Tests.swift
//  MusicPlayer1.5Tests
//
//  Created by William  Uchegbu on 9/3/17.
//  Copyright © 2017 William  Uchegbu. All rights reserved.
//

import XCTest
@testable import MusicPlayer1_5

class MusicPlayer1_5Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let x = appDelegate.arrayPos
        XCTAssertEqual(x, 5, "Error: array index out of bounds")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

//
//  MyPhotosOnAMapTests.swift
//  MyPhotosOnAMapTests
//
//  Created by Christian Dunn on 4/19/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import XCTest
@testable import MyPhotosOnAMap

class MyPhotosOnAMapTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCDStack() {
        let StackTest : CDStack<Int> = CDStack<Int>.init();
        StackTest.push(10);
        StackTest.push(20);
        StackTest.push(30);
        StackTest.push(40);
        StackTest.push(50);
        
        let firstPop = StackTest.pop();
        XCTAssert(firstPop == 50);
        StackTest.push(51);
        XCTAssert(StackTest.pop() == 51);
        XCTAssert(StackTest.count() == 4);
        XCTAssert(StackTest.pop() == 40);
        StackTest.removeAll();
        XCTAssert(StackTest.count() == 0);
        XCTAssert(StackTest.pop() == nil);
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}

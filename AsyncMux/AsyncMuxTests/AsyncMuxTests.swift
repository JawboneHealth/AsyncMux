//
//  AsyncMuxTests.swift
//  AsyncMuxTests
//
//  Created by Lissy Harrison on 6/20/23.
//

import XCTest
@testable import AsyncMux

final class AsyncMuxTests: XCTestCase {
    var sut: MuxDB!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MuxDB()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testSave() {
        let testKey = "TEST"
        let testData = "THIS DATA"

        XCTAssertEqual(sut.save(key: testKey, data: testData), "Success")
    }
    
    func testUpdate() {
        let testKey = "TEST"
        let testData = "THIS DATA"

        XCTAssertEqual(sut.update(key: testKey, data: testData), "Success")
    }
    
    func testDelete() {
        let testKey = "TEST"
        let testData = "THIS DATA"
        sut.save(key: testKey, data: testData)
        
        XCTAssertEqual(sut.delete(keyToDelete: testKey), "Success")
    }

}

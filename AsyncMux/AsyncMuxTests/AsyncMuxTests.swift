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
    
    struct Athlete: Codable {
        let name: String
        let sport: String
        let rank: Int64
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MuxDB()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testSaveAndLoad() {
        let testData = Athlete(name: "Lindsey", sport: "skiing", rank: 1)
    }
    
    func testDelete() {
       
    }
    
    func testDeleteAll() {
        
    }

}

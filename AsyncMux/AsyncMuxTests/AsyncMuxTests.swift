//
//  AsyncMuxTests.swift
//  AsyncMuxTests
//
//  Created by Lissy Harrison on 6/26/23.
//

import XCTest
@testable import AsyncMux

final class AsyncMuxTests: XCTestCase {
    
    var sut: MuxDB!
    
    struct Athlete: Codable, Equatable {
        let domain: String
        let name: String
        let sport: String
        let rank: Int64
    }
    
    struct Car: Codable, Equatable {
        let domain: String
        let make: String
        let model: String
        let year: Int64
    }
    
    let defaultAthelete = Athlete(domain: "Atheletes", name: "Default", sport: "Default", rank: 0)
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MuxDB.shared
        
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testSaveAndLoad() throws {
        let testData = Athlete(domain: "Athletes", name: "Bode", sport: "skiing", rank: 1)
        var athlete: Athlete
        
        sut.save(key: "\(testData.domain)/\(testData.name)", data: testData)
        
        athlete = sut.load(keyToLoad: "\"\(testData.domain)/\(testData.name)\"", type: Athlete.self) ?? defaultAthelete
        
        XCTAssertEqual(testData, athlete)
        
    }
    
    func testUpdateWhenEntryAlreadyExists() throws {
        let testData = Athlete(domain: "Athletes", name: "Lindsey", sport: "skiing", rank: 1)
        let testData1 = Athlete(domain: "Athletes", name: "Lindsey", sport: "snowboarding", rank: 2)
        var athlete: Athlete
        
        sut.save(key: "\(testData.domain)/\(testData.name)", data: testData)
        sut.save(key: "\(testData.domain)/\(testData.name)", data: testData1)
        
        athlete = sut.load(keyToLoad: "\"\(testData.domain)/\(testData.name)\"", type: Athlete.self) ?? defaultAthelete
        
        XCTAssertEqual(testData1, athlete)
        
    }
    
    func testDelete() throws {
        let testData = Athlete(domain: "Athletes", name: "Lindsey", sport: "skiing", rank: 1)
        var athletes: [Athlete]
        
        sut.save(key: "\(testData.domain)/\(testData.name)", data: testData)
        
        sut.delete(keyToDelete: "\(testData.domain)/\(testData.name)")
        
        athletes = sut.loadAll(domain: "Athletes", type: Athlete.self)!
        
        XCTAssertEqual(athletes.count, 0)
        
    }
    
    func testDeleteAll() throws {
        let testData1 = Athlete(domain: "Athletes", name: "Lindsey", sport: "skiing", rank: 1)
        let testData2 = Athlete(domain: "Athletes", name: "Lindsey", sport: "skiing", rank: 1)
        let testData3 = Car(domain: "Cars", make: "Toyota", model: "Tundra", year: 2018)
        let testData4 = Car(domain: "Cars", make: "Ford", model: "F350", year: 2008)
        
        sut.save(key: "\(testData1.domain)/\(testData1.name)", data: testData1)
        sut.save(key: "\(testData2.domain)/\(testData2.name)", data: testData2)
        sut.save(key: "\(testData3.domain)/\(testData3.model)", data: testData3)
        sut.save(key: "\(testData4.domain)/\(testData4.model)", data: testData4)
        
        sut.deleteAll(domainToDelete: "Athletes")
        
        let returnData = sut.loadAll(domain: "Athletes", type: Athlete.self)!
        XCTAssertEqual(returnData.count, 0)
        
        
    }
    
}

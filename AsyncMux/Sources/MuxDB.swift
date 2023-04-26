//
//  MuxDB.swift
//  AsyncMux
//
//  Created by Lissy Harrison on 4/17/23.
//

import Foundation
import SQLite3
import SQLite



private class DBConnection {
    private static let shared = DBConnection()
    var db: Connection
    
    
    private let key = Expression<Int>("id")
    private let data = Expression<String>("data")
    private let dataTable = Table("savedData")
    
    private init() {
        var dbPath = "thisDatabase"
        
        let db = {
            return try! Connection("\(dbPath)/data.sqlite")
        }()
        do {
            try db.run(dataTable.create { table in
                table.column(key)
                table.column(data)
            })
            print("Table Created...")
        } catch {
            print(error)
        }
    }
    
    private static func load<T: Decodable>(db: Connection, key: String, type: T.Type) -> T? {
        
        do {
            for row in try db.prepare(dataTable) {
                
                
            }
        }
        catch let error as NSError {
                    print("Error: \(error.description)")
                }
        return try? JSONDecoder().decode(type, from: Data(contentsOf: cacheFileURL(domain: domain, key: key, create: false)))
    }
    
    private static func save<T>(db: Connection?, dataTable: Table, data: T) -> Int64? {
        guard let database = db else { return nil }
        
        let insert = dataTable.insert(data)
        do {
            let rowID = try database.run(insert)
            return rowID
        } catch {
            print(error)
            return nil
        }
    }
    public static func save<T: Encodable>(_ result: T, domain: String, key: String) {
        let json = try! JSONEncoder().encode(result)
        
    }
    
    public static func delete(db: Connection?, dataTable: Table, id: Int) -> Bool {
        guard let database = db else {
            return false
        }
        do {
            let filter = dataTable.filter(self.key == key)
            try database.run(filter.delete())
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    public static func delete(domain: String, key: String) {
        try? FileManager.default.removeItem(at: cacheFileURL(domain: domain, key: key, create: false))
    }
}

//
//  MuxDB.swift
//  AsyncMux
//
//  Created by Lissy Harrison on 4/17/23.
//

import Foundation
import SQLite3
import SQLite



class MuxDB {
    static let shared = MuxDB()
    private var db: Connection
    
    
    private let key = Expression<String>("key")
    private let data = Expression<Data>("data")
    private let dataTable = Table("savedData")
    
    private init() {
        db = try! Connection("/Users/lisa/PiTech/all.health/AsyncMux/muxDB.db")
       do {
           try db.run(dataTable.create(ifNotExists: true) { table in
               table.column(key, unique: true)
                table.column(data)
            })
            print("Table Created...")
        } catch {
            print(error)
        }
    }
    
    func save<T: Encodable>(key: String, data: T) -> Int64? {
        let json = try! JSONEncoder().encode(data)
        
        let insert = dataTable.insert(or: .replace,
            self.key <- key,
            self.data <- json
            )
        do {
            let rowID = try db.run(insert)
            return rowID
        } catch {
            print(error)
            return nil
        }
    }
    
    func delete(keyToDelete: String) {
        let itemToDelete = dataTable.filter(key == keyToDelete)
        do {
            try db.run(itemToDelete.delete())
        } catch {
            print(error)
        }
    }
    
}

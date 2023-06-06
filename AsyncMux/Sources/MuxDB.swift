//
//  MuxDB.swift
//  AsyncMux
//
//  Created by Lissy Harrison on 6/5/23.
//

import Foundation
import SQLite3

class MuxDB {
    static let shared = MuxDB()
    
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    // specifies to store database in Files app on user's device
    private var dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    
    private var db: OpaquePointer?
    
    private init() {
        db = openDatabase()
        
        if(!createTable()) {
            print ("Error creating table in initializer")
        } else {
            print ("Table created in initializer")
        }
        
    }
    // create database
    func openDatabase() -> OpaquePointer? {
        
        let url = NSURL(fileURLWithPath: dbPath)
        
        // names db
        if let pathComponent = url.appendingPathComponent("MuxDB") {
            let filePath = pathComponent.path
            if sqlite3_open(filePath, &db) == SQLITE_OK {
                print("Successfully opened database at \(filePath)")
                return db
            } else {
                print("Error opening database at \(filePath)")
            }
        } else {
            print("Filepath is not available")
        }
        
        return db
    }
    
    // create a table in database
    
    func createTable() -> Bool {
        var success: Bool = false
        
        let createTable = sqlite3_exec(db, "CREATE TABLE IF NOT EXIST SAVED (KEY TEXT NULL, DATA TEXT NULL)", nil, nil, nil)
        
        if(createTable != SQLITE_OK) {
            print("Error creating table")
            success = false
        } else {
            print("Table created successfully")
            success = true
        }
        return success
    }
    
    func save<T: Encodable>(key: String, data: T) -> Int64? {
        let json = try! JSONEncoder().encode(data)
        let str = String(decoding: json, as: UTF8.self)
        
        let insertStatement = "INSERT INTO SAVED (KEY, DATA) VALUES (?, ?);"
        
        var insertQuery: OpaquePointer?
        
        if(sqlite3_prepare_v2(db, insertStatement, -1, &insertQuery, nil)) == SQLITE_OK {
            sqlite3_bind_text(insertQuery, 1, key, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(insertQuery, 2, str, -1, SQLITE_TRANSIENT)
            
            if(sqlite3_step(insertQuery) == SQLITE_DONE) {
                print("Data saved successfully")
            } else {
                print("Error saving data")
            }
            
            sqlite3_finalize(insertQuery)
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
    
    func deleteAll() {
        do {
            try db.run(dataTable.delete())
        } catch {
            print(error)
        }
    }
    
    func load<T: Decodable>(keyToLoad: String, type: T.Type) -> T? {
        let loadString = "SELECT KEY, DATA FROM SAVED WHERE KEY = '\(keyToLoad)'"
        
        var loadQuery: OpaquePointer?
        
        var showData: Data
        var decodedData: T
        
        if sqlite3_prepare_v2(db, loadString, -1, &loadQuery, nil) == SQLITE_OK {
            
            showData = (String(cString: sqlite3_column_text(loadQuery, 1)).data(using: .utf8)!)
            
        }
        print("Data loaded \(showData)")
        sqlite3_finalize(loadQuery)
        
        do{
            try decodedData = JSONDecoder().decode(type, from: showData)
        } catch {
            print("Error decoding data")
        }
        
        return decodedData
        
    }
    
    func loadAll<T: Decodable>(domain: String, type: T.Type) -> [T]? {
        let loadString = "SELECT KEY, DATA FROM SAVED"
        
        var loadQuery: OpaquePointer?
        
        var showData: [Data] = []
        var decodedData: [T] = []
        
        if sqlite3_prepare_v2(db, loadString, -1, &loadQuery, nil) == SQLITE_OK {
            while sqlite3_step(loadQuery) == SQLITE_ROW {
                
                showData.append(String(cString: sqlite3_column_text(loadQuery, 1)).data(using: .utf8)!)
            }
        }
        print("Data loaded \(showData)")
        sqlite3_finalize(loadQuery)
        
        for data in showData {
            do{
                try decodedData.append(JSONDecoder().decode(type, from: data))
            } catch {
                print("Error decoded data")
            }
            
        }
        
        return decodedData
        
    }
}

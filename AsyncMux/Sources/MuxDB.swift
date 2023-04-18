//
//  MuxDB.swift
//  AsyncMux
//
//  Created by Lissy Harrison on 4/17/23.
//

import Foundation
import SQLite3
import SQLite


public class WeatherDataStore {

  static let DIR_TASK_DB = "WeatherDB"
  static let STORE_NAME = "weather.sqlite3"

  private let weather = Table("weather")

  private let id = Expression<Int>("id")
  private let place = Expression<String>("place")
  private let temperature = Expression<Double>("temp")
  private let weatherCode = Expression<Int>("weatherCode")
  
  struct WeatherData {
    let id: Int
    let place: String
    let temperature: Double
    let weatherCode: Int
  }

  private var db: Connection? = nil

  private init() {
    if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      let dirPath = docDir.appendingPathComponent(Self.DIR_TASK_DB)

      do {
        try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
        let dbPath = dirPath.appendingPathComponent(Self.STORE_NAME).path
        db = try Connection(dbPath)
        createTable()
        print("SQLiteDataStore init successfully at: \(dbPath) ")
      } catch {
        db = nil
        print("SQLiteDataStore init error: \(error)")
      }
    } else {
      db = nil
    }
  }

  private func createTable() {
    guard let database = db else {
      return
    }
    do {
      try database.run(weather.create { table in
        table.column(id, primaryKey: .autoincrement)
        table.column(place)
        table.column(temperature)
        table.column(weatherCode)
      })
      print("Table Created...")
    } catch {
      print(error)
    }
  }
  
  func insert(thisWeather: WeatherData) -> Int64? {
      guard let database = db else { return nil }

    let insert = weather.insert(self.place <- place,
                                self.temperature <- temperature,
                                self.weatherCode <- weatherCode)
      do {
          let rowID = try database.run(insert)
          return rowID
      } catch {
          print(error)
          return nil
      }
  }
  
  
  func getAll() -> [WeatherData] {
      var weathers: [WeatherData] = []
      guard let database = db else { return [] }

      do {
          for thisWeather in try database.prepare(self.weather) {
            weathers.append(WeatherData(id: thisWeather[id], place: thisWeather[place], temperature: thisWeather[temperature], weatherCode: thisWeather[weatherCode]))
          }
      } catch {
          print(error)
      }
      return weathers
  }
  
  func delete(id: Int) -> Bool {
      guard let database = db else {
          return false
      }
      do {
          let filter = weather.filter(self.id == id)
          try database.run(filter.delete())
          return true
      } catch {
          print(error)
          return false
      }
  }
  
  func deleteTable(table: String) -> Bool {
    guard let database = db else {
      return false
    }
    do {
      try database.run(weather.drop())
      return true
    } catch {
      print(error)
      return false
    }
  }
}

public class MuxDB {

    public static func load<T: Decodable>(domain: String, key: String, type: T.Type) -> T? {
      // needs to change to WeatherDataStore.getAll()
        return try? JSONDecoder().decode(type, from: Data(contentsOf: cacheFileURL(domain: domain, key: key, create: false)))
    }

    public static func save<T: Encodable>(_ result: T, domain: String, key: String) {
      // needs to change to WeatherDataStore.insert()
      let json = try! JSONEncoder().encode(result).write(to: cacheFileURL(domain: domain, key: key, create: true), options: .atomic)
    }

    public static func delete(domain: String, key: String) {
      // needs to change to WeatherDataStore.delete()
        try? FileManager.default.removeItem(at: cacheFileURL(domain: domain, key: key, create: false))
    }

    public static func deleteDomain(_ domain: String) {
      // needs to change to WeatherDataStore.deleteTable()
        try? FileManager.default.removeItem(at: cacheDirURL(domain: domain, create: false))
    }

    private static func cacheFileURL(domain: String, key: String, create: Bool) -> URL {
        return cacheDirURL(domain: domain, create: create).appendingPathComponent(key).appendingPathExtension("json")
    }

    private static func cacheDirURL(domain: String, create: Bool) -> URL {
        let dir = "AsyncMux/" + domain
        return FileManager.default.cachesDirectory(subDirectory: dir, create: create)
    }
}

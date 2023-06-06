//
//  MuxCacher.swift
//  AsyncMux
//
//  Created by Hovik Melikyan on 09/01/2023.
//  Copyright © 2023 Hovik Melikyan. All rights reserved.
//

import Foundation


public class MuxCacher {
    
    public static func load<T: Decodable>(domain: String, key: String, type: T.Type) -> T? {
        return MuxDB.shared.load(keyToLoad: domain + "/" + key, type: type)
    }
    
    public static func save<T: Encodable>(_ object: T, domain: String, key: String) {
        MuxDB.shared.save(key: domain + "/" + key, data: object)
    }
    public static func update<T: Encodable>(_ object: T, domain: String, key: String) {
        MuxDB.shared.update(key: domain + "/" + key, data: object)
    }
    
    public static func delete(domain: String, key: String) {
        MuxDB.shared.delete(keyToDelete: domain + "/" + key);
    }
    
    public static func deleteDomain(_ domain: String) {
        MuxDB.shared.deleteAll();
    }
}

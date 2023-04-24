//
//  AsyncMuxDemoApp.swift
//  AsyncMuxDemo
//
//  Created by Hovik Melikyan on 07/01/2023.
//

import SwiftUI
import AsyncMux

@main
struct AsyncMuxDemoApp: App {
    @Environment(\.scenePhase) var scenePhase
  
 
      
  init() {
    if DBConnection.conn != nil {
      do {
        try DBConnection.open(dbPath: FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0])
      } catch {
        print("error")
      }
    } else {
      print("Connection already existed")
    }
  }

    var body: some Scene {
        scene()
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                    case .background:
                        Task {
                            await MuxRepository.shared.saveAll()
                        }
                    case .inactive:
                        break
                    case .active:
                        break
                    @unknown default:
                        break
                }
            }
    }

    func scene() -> some Scene {
#if os(iOS)
        WindowGroup {
            ContentView()
        }
#else
        Window("AsyncMux Demo", id: String(describing: self)) {
            ContentView()
        }
#endif
    }
}

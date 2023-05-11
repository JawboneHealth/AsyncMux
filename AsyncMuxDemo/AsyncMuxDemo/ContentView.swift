//
//  ContentView.swift
//  AsyncMuxDemo
//
//  Created by Hovik Melikyan on 07/01/2023.
//

import UIKit // for UIImage
import SwiftUI
import AsyncMux


private let backgroundURL = URL(string: "https://images.unsplash.com/photo-1513051265668-0ebab31671ae")!

class WeatherItems: ObservableObject {
    @Published var items: [WeatherItem] = []
}

struct ContentView: View {
    
    @State var items: [WeatherItem] = []
    @State var isLoading: Bool = false
    @State var selectedCity: String = ""
    @State var citiesToDisplay: [String] = []
    let cities: [String] = ["New York", "London", "Paris", "Tokyo"]
    
    var body: some View {
        listView()
            .background(backgroundImageView())
            .preferredColorScheme(.dark)
        
            .serverTask(withAlert: true) {
                items = try await WeatherAPI.reload(refresh: false, placeNames: <#T##[String]#>)
            }
        
            .serverRefreshable(withAlert: false) {
                items = try await WeatherAPI.reload(refresh: true)
            }
    }
    
    @MainActor // this is because List() generates an error in strict mode, an Apple bug
    @ViewBuilder
    private func listView() -> some View {
        if isLoading, items.isEmpty {
            Color.clear
                .overlay(ProgressView())
        }
        else {
            Picker("Please choose a color", selection: $selectedCity) {
                ForEach(cities, id: \.self) {
                    Text($0)
                }
            }
            .onChange(of: selectedCity) { _ in
                if !citiesToDisplay.contains(selectedCity) {
                    citiesToDisplay.append(selectedCity)
                }
            }
        }
        List {
            ForEach(items, id: \.self) { item in
                if citiesToDisplay.contains(item.place.city) {
                    HStack {
                        Text("\(item.place.city), \(item.place.countryCode)")
                        Spacer()
                        Text(item.weather.map { "\(Int(round($0.currentWeather.temperature)))ºC" } ?? "-")
                        Button(action: {
                            items.remove(at:items.firstIndex(of: item)!)
                            citiesToDisplay.remove(at: citiesToDisplay.firstIndex(of: item.place.city)!)
                        }, label: {
                            Text("Delete")
                        })
                    }
                    .listRowBackground(Color.clear)
                }
                
            }
        }
        .listStyle(.inset)
        .font(.title2)
        .scrollContentBackground(.hidden)
    }
}

private func backgroundImageView() -> some View {
    RemoteImage(url: backgroundURL) { image in
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    } placeholder: {
        Color(UIColor.systemBackground)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(items: [
            .init(place: .init(city: "London", countryCode: "GB", lat: "51.51", lon: "-0.13"), weather: .init(currentWeather: .init(temperature: 8.1, weathercode: 2))),
            .init(place: .init(city: "Paris", countryCode: "FR", lat: "48.84", lon: "2.36"), weather: .init(currentWeather: .init(temperature: 10.2, weathercode: 3)))
        ])
    }
}

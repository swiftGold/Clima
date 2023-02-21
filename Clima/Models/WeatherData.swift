//
//  WeatherData.swift
//  Clima
//
//  Created by Сергей Золотухин on 16.02.2023.
//

struct WeatherData: Codable {
    let name: String
    let main: MainStruct
    let weather: [WeatherStruct]
}

struct MainStruct: Codable {
    let temp: Double
}

struct WeatherStruct: Codable {
    let description: String
    let id: Int
}

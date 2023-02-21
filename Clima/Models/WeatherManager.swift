//
//  WeatherManager.swift
//  Clima
//
//  Created by Сергей Золотухин on 15.02.2023.
//

protocol WeatherManagerDelegate: AnyObject {
    func didUpdateWeatherVC(with model: WeatherModel)
    func didFailWithError(error: Error)
}

import Foundation
import CoreLocation

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?"
    let apiKey = "8fbec5bc2a5ea5e5c995dfe936308e7e"
    
    weak var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)q=\(cityName)&&appid=\(apiKey)&units=metric"
        print(urlString)
        performRequest(urlString: urlString)
    }
    
    func fetchWeatherByCoordinates(lat: Double, long: Double) {
        let urlString = "\(weatherURL)lat=\(lat)&lon=\(long)&appid=\(apiKey)&units=metric"
        print(urlString)
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        //1.Create a URL
        guard let url = URL(string: urlString) else { fatalError() }
        //2. Create a URLsession
        let session = URLSession(configuration: .default)
        //3. Give the session a task
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                self.delegate?.didFailWithError(error: error!)
                return
            }
            
            if let safeData = data {
                if let weather = self.parseJSON(weatherData: safeData) {
                    self.delegate?.didUpdateWeatherVC(with: weather)
                }
            }
        }
        //4. Start the task
        task.resume()
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

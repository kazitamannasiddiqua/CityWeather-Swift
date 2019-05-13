//
//  APIService.swift
//  CityWeather
//
//  Created by Jun Dang on 2019-05-12.
//  Copyright © 2019 Jun Dang. All rights reserved.
//
import UIKit
import Foundation
import CoreData


enum Units: String {
    case Metric = "metric"
    case Imperial = "imperial"
}

struct OpenWeatherMapAPI {
    static let BASE_URLString = "http://api.openweathermap.org/data/2.5/weather"
    static let APPID = "bfce8c36a56599370b2872ccf17d907c"
    static let units: Units = .Metric
}

class APIService: NSObject {
    
    static let sharedInstance: APIService = { return APIService() }()
    typealias weatherResult = (Forecast?, String) -> ()
    var forecast: Forecast??
    var errorMessage = ""
    
    
    func getCurrentWeather(cityName: String, completion: @escaping weatherResult) {
        let parameters = [
            "q": "\(cityName)",
            "APPID": OpenWeatherMapAPI.APPID,
            "units": OpenWeatherMapAPI.units.rawValue,
        ]
        fetchWeatherForURL(OpenWeatherMapAPI.BASE_URLString, parameters: parameters, completion: completion)
    }
    
    func fetchWeatherForURL(_ baseURL: String = "", parameters: [String: String] = [:], completion: @escaping weatherResult) {
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = parameters.map(URLQueryItem.init)
        
        guard let url = components.url else {
            errorMessage += "error: URL Cannot be Encoded"
            return
        }
        print("url: \(url)")
        dataTask = defaultSession.dataTask(with: url) { data, response, error in
            defer { dataTask = nil }
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                print(self.errorMessage)
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                self.parseJsonData(data)
                DispatchQueue.main.async {
                    if let forecast = self.forecast {
                        completion(forecast, self.errorMessage)
                    }
                }
            }
        }
        dataTask?.resume()
    }
    
    func parseJsonData(_ data: Data) {
        
        let jsonData = String(data: data, encoding: String.Encoding.utf8)
 
        do {
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            forecast = try decoder.decode(Forecast.self, from: data)
           
            
           } catch let jsonError {
            //print("JsonError: " + "\(jsonError.localizedDescription)")
            self.errorMessage += "ParsingJSON error: " + jsonError.localizedDescription + "\n"
        }
    }
}


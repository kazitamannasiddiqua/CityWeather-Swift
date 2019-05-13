//
//  Forecast.swift
//  CityWeather-3
//
//  Created by Jun Dang on 2019-05-12.
//  Copyright © 2019 Jun Dang. All rights reserved.
//
import Foundation

public class Forecast: Codable {
    
    var cityID: Int
    var cityName: String
    var coordinates: Coordinates
    var weatherCondition: [WeatherCondition]
    var temperatures: Temperature
    var time: Int
    
    enum CodingKeys: String, CodingKey {
        case cityID = "id"
        case cityName = "name"
        case coordinates = "coord"
        case weatherCondition = "weather"
        case temperatures = "main"
        case time = "dt"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.cityID = try values.decode(Int.self, forKey: .cityID)
        self.cityName = try values.decode(String.self, forKey: .cityName)
        self.coordinates = try values.decode(Coordinates.self, forKey: .coordinates)
        self.weatherCondition = try values.decode([WeatherCondition].self, forKey: .weatherCondition)
        self.temperatures = try values.decode(Temperature.self, forKey: .temperatures)
        self.time = try values.decode(Int.self, forKey: .time)
        
    }
}

class Coordinates: Codable {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
    required convenience public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 0.0
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 0.0
    }
}

class WeatherCondition: Codable {
    var identifier: Int = 0
    var conditionName: String = ""
    var conditionDescription: String = ""
    var conditionIconCode: String = ""
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case conditionName = "main"
        case conditionDescription = "description"
        case conditionIconCode = "icon"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decodeIfPresent(Int.self, forKey: .identifier) ?? 0
        self.conditionName = try container.decodeIfPresent(String.self, forKey: .conditionName) ?? ""
        self.conditionDescription = try container.decodeIfPresent(String.self, forKey: .conditionDescription) ?? ""
        self.conditionIconCode = try container.decodeIfPresent(String.self, forKey: .conditionIconCode) ?? ""
        //self.init(identifier, conditionName, conditionDescription,conditionIconCode)
    }
}

class Temperature: Codable {
    var temperatureKelvin: Double = 0.0
    var humidity: Double = 0.0
    var pressure: Double = 0.0
    var tempMin: Double = 0.0
    var tempMax: Double = 0.0
    
    
    enum CodingKeys: String, CodingKey {
        case temperatureKelvin = "temp"
        case pressure
        case humidity
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.temperatureKelvin = try container.decodeIfPresent(Double.self, forKey: .temperatureKelvin) ?? 0.0
        self.pressure = try container.decodeIfPresent(Double.self, forKey: .pressure) ?? 0.0
        self.humidity = try container.decodeIfPresent(Double.self, forKey: .humidity) ?? 0.0
        self.tempMin = try container.decodeIfPresent(Double.self, forKey: .tempMin) ?? 0.0
        self.tempMax = try container.decodeIfPresent(Double.self, forKey: .tempMax) ?? 0.0
        //self.init(temperatureKelvin, humidity, pressure, tempMin, tempMax)
    }
}


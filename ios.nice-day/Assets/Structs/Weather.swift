//
//  Weather.swift
//  ios.nice-day
//
//  Created by Frank van Boheemen on 03/09/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Weather {
    let temp: Double // Kelvin
    let pressure: Int // hPa
    let humidity: Double // Percentage humidity
    let rain: Int? // Rain volume for the last 1 hour, mm -> Optional, because OpenWeather does not provide parameters for weather phenomena that are not happening
    let wind: Wind
    let clouds: Double? // Percentage cloudiness
    
    struct Wind {
        let direction: Int // Degrees (meteorological)
        let speed: Double // m/s
    }
    
    init?(data: Any) {
        let json = JSON(data)
        guard
            let parsedTemp = json["main"]["temp"].double,
            let parsedPressure = json["main"]["pressure"].int,
            let parsedHumidity = json["main"]["humidity"].double,
            let parsedWindDirection = json["wind"]["deg"].int,
            let parsedWindSpeed = json["wind"]["speed"].double,
            let parsedClouds = json["clouds"]["all"].double else { return nil }
        
        temp = parsedTemp
        pressure = parsedPressure
        humidity = parsedHumidity/100
        rain = json["rain"]["rain.1h"].int
        wind = Wind(direction: parsedWindDirection, speed: parsedWindSpeed)
        clouds = parsedClouds/100
    }
}

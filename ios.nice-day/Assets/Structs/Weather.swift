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
    let humidity: Double // Percentage humidity
    let rain: Double? // Rain volume for the last 1 hour, mm -> Optional, because OpenWeather does not provide parameters for weather phenomena that are not happening
    let wind: Wind
    let cloudiness: Double? // Percentage cloudiness
    
    struct Wind {
        let direction: Double // Degrees (meteorological)
        let speed: Double // m/s
    }
    
    init?(data: Any) {
        let json = JSON(data)
        guard
            let parsedTemp = json["main"]["temp"].double,
            let parsedHumidity = json["main"]["humidity"].double,
            let parsedWindDirection = json["wind"]["deg"].double,
            let parsedWindSpeed = json["wind"]["speed"].double,
            let parsedClouds = json["clouds"]["all"].double else { return nil }
        
        temp = parsedTemp
        humidity = parsedHumidity/100
        rain = json["rain"]["rain.1h"].double
        wind = Wind(direction: parsedWindDirection, speed: parsedWindSpeed)
        cloudiness = parsedClouds/100
    }
}

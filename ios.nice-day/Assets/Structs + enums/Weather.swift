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
    let temp: Float // Kelvin
    let humidity: Float // Percentage humidity
    let rain: Float? // Rain volume for the last 1 hour, mm -> Optional, because OpenWeather does not provide parameters for weather phenomena that are not happening
    let wind: Wind
    let cloudiness: Float? // Percentage cloudiness
    
    struct Wind {
        let direction: Float // Degrees (meteorological)
        let speed: Float // m/s
    }
    
    init?(data: Any) {
        let json = JSON(data)
        guard
            let parsedTemp = json["main"]["temp"].float,
            let parsedHumidity = json["main"]["humidity"].float,
            let parsedWindDirection = json["wind"]["deg"].float,
            let parsedWindSpeed = json["wind"]["speed"].float,
            let parsedClouds = json["clouds"]["all"].float else { return nil }
        
        temp = parsedTemp
        humidity = parsedHumidity/100
        rain = json["rain"]["rain.1h"].float
        wind = Wind(direction: parsedWindDirection, speed: parsedWindSpeed)
        cloudiness = parsedClouds/100
    }
}

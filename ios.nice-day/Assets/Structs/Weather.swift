//
//  Weather.swift
//  ios.nice-day
//
//  Created by Frank van Boheemen on 03/09/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import Foundation

struct Weather {
    let temp: Double // Kelvin
    let pressure: Int // hPa
    let humidity: Double // Percentage humidity
    let rain: Int? // Rain volume for the last 1 hour, mm
    let wind: Wind
    let clouds: Double? // Percentage cloudiness
    
    struct Wind {
        let direction: Int // Degrees (meteorological)
        let speed: Double // m/s
    }
}

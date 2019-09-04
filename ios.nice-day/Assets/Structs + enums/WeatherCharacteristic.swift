//
//  WeatherCharacteristic.swift
//  ios.nice-day
//
//  Created by Frank van Boheemen on 04/09/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import Foundation

enum WeatherCharacteristic: String, CaseIterable {
    case temperature = "temperature"
    case humidity = "humidity"
    case rainfall = "rainfall"
    case windSpeed = "windSpeed"
    case cloudiness = "cloudiness"
}

//
//  MainInteractor.swift
//  ios.nice-day
//
//  Created by Frank van Boheemen on 03/09/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import Foundation

protocol MainInteractorDelegate {
    
}

class MainInteractor {
    var presenter: MainInteractorDelegate?
    var openWeatherService: OpenWeatherService?
    
    init() {
        openWeatherService = OpenWeatherService()
        openWeatherService?.weatherForCoordinates() { (response, error) in
            guard let weather = response else {
                print("\(error)")
                return
            }
//            print("\(response)")
            self.qualify(weather: weather)
        }
    }
    
    //Temporary hardcoded preference
    let preferredMinTemp: Double = 18
    let preferredMaxTemp: Double = 27
    let preferredMaxHumidity: Double = 0.8
    let preferredMaxRainfall: Double = 0
    let preferredMaxWindSpeed: Double = 8
    let preferredMaxCloudiness: Double = 0.2
    
    func qualify(weather: Weather) {
        var weatherRating = 10
        
        weatherRating -= determinePenalty(weatherCharacteristic: weather.temp, preference: preferredMinTemp, preferenceType: .minValue)
        weatherRating -= determinePenalty(weatherCharacteristic: weather.temp, preference: preferredMaxTemp, preferenceType: .maxValue)
        weatherRating -= determinePenalty(weatherCharacteristic: weather.humidity, preference: preferredMaxHumidity, preferenceType: .maxValue)
        if let rain = weather.rain {
            weatherRating -= determinePenalty(weatherCharacteristic: rain, preference: preferredMaxRainfall, preferenceType: .maxValue)
        }
        weatherRating -= determinePenalty(weatherCharacteristic: weather.wind.speed, preference: preferredMaxWindSpeed, preferenceType: .maxValue)
        if let cloudiness = weather.cloudiness {
            weatherRating -= determinePenalty(weatherCharacteristic: cloudiness, preference: preferredMaxCloudiness, preferenceType: .maxValue)
        }
        
        print("weatherRating: \(weatherRating)")
    }
    
    //Penalties are determined by how much the parameter deviates from the preferred parameter and is capped off on a maximum of 2
    private func determinePenalty(weatherCharacteristic: Double, preference: Double, preferenceType: PreferenceType) -> Int {
        let penalty: Int
        switch preferenceType {
        case .minValue:
            if weatherCharacteristic < preference {
                if preference == 0 {
                    penalty = floor(weatherCharacteristic / 10) < 2 ? Int(weatherCharacteristic / 10) : 2
                } else {
                    let deviation : Double = (preference - weatherCharacteristic) / preference
                    penalty = ceil(deviation * 10) < 2 ? Int(ceil(deviation * 10)) : 2
                }
            } else {
                penalty = 0
            }
        case .maxValue:
            if weatherCharacteristic > preference {
                if preference == 0 {
                    penalty = floor(weatherCharacteristic / 10) < 2 ? Int(weatherCharacteristic / 10) : 2
                } else {
                    let deviation : Double = Double((weatherCharacteristic - preference) / preference)
                    penalty = ceil(deviation * 10) < 2 ? Int(ceil(deviation * 10)) : 2
                }
            } else {
                penalty = 0
            }
        }
        
        return penalty
    }
}

//
//  MainInteractor.swift
//  ios.nice-day
//
//  Created by Frank van Boheemen on 03/09/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import Network

protocol MainInteractorDelegate {
    func qualified(weather: Weather, score: Int)
}

class MainInteractor: NSObject {
    var presenter: MainInteractorDelegate?
    var openWeatherService: OpenWeatherService?
    var locationManager: CLLocationManager?
    var monitor: NWPathMonitor?
    
    override init() {
        super.init()
        startMonitoringInternetConnection()
        registerDefaultPreferences()
    }
    
    private func startMonitoringInternetConnection() {
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
        monitor?.start(queue: queue)
    }
    
    //MARK: - Preferences
    private func registerDefaultPreferences() {
        let defaults: [String : Float] = [WeatherCharacteristic.lowerTemperature.rawValue : 18,
                                          WeatherCharacteristic.upperTemperature.rawValue : 27,
                                          WeatherCharacteristic.humidity.rawValue : 0.8,
                                          WeatherCharacteristic.rainfall.rawValue : 0,
                                          WeatherCharacteristic.windSpeed.rawValue : 3,
                                          WeatherCharacteristic.cloudiness.rawValue : 0]
        
        UserDefaults.standard.register(defaults: defaults)
    }
    
    
    func loadPreferences() -> Preferences {
        return Preferences(lowerTemperature: UserDefaults.standard.float(forKey: WeatherCharacteristic.lowerTemperature.rawValue),
                           upperTemperature: UserDefaults.standard.float(forKey: WeatherCharacteristic.upperTemperature.rawValue),
                           humidity: UserDefaults.standard.float(forKey: WeatherCharacteristic.humidity.rawValue),
                           rainfall: UserDefaults.standard.float(forKey: WeatherCharacteristic.rainfall.rawValue),
                           windSpeed: UserDefaults.standard.float(forKey: WeatherCharacteristic.windSpeed.rawValue),
                           cloudiness: UserDefaults.standard.float(forKey: WeatherCharacteristic.cloudiness.rawValue))
    }
    
    func savePreference(characteristic: WeatherCharacteristic, newValue: Float) {
        let userDefaultsKey: String = characteristic.rawValue
        UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
    }
    
    //MARK: - Qualifying weather
    
    func qualifyWeatherAtCurrentLocation() {
        guard let connectivityStatus = monitor?.currentPath.status, connectivityStatus == .satisfied else {
            //TODO: Tell the user there is no connection to the internet
            return
        }
        
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager?.requestLocation()
        }
        openWeatherService = OpenWeatherService()
    }
    
    
    private func qualify(weather: Weather) {
        let preferences = loadPreferences()
        var weatherRating = 10
        
        weatherRating -= determinePenalty(weatherCharacteristic: weather.temp, preference: preferences.lowerTemperature, preferenceType: .minValue)
        weatherRating -= determinePenalty(weatherCharacteristic: weather.temp, preference: preferences.upperTemperature, preferenceType: .maxValue)
        weatherRating -= determinePenalty(weatherCharacteristic: weather.humidity, preference: preferences.humidity, preferenceType: .maxValue)
        if let rain = weather.rain {
            weatherRating -= determinePenalty(weatherCharacteristic: rain, preference: preferences.rainfall, preferenceType: .maxValue)
        }
        weatherRating -= determinePenalty(weatherCharacteristic: weather.wind.speed, preference: preferences.windSpeed, preferenceType: .maxValue)
        if let cloudiness = weather.cloudiness {
            weatherRating -= determinePenalty(weatherCharacteristic: cloudiness, preference: preferences.cloudiness, preferenceType: .maxValue)
        }
        
        print("weatherRating: \(weatherRating)")
        presenter?.qualified(weather: weather, score: weatherRating)        
    }
    
    //Penalties are determined by how much the parameter deviates from the preferred parameter and is capped off on a maximum of 2
    private func determinePenalty(weatherCharacteristic: Float, preference: Float, preferenceType: PreferenceType) -> Int {
        let penalty: Int
        switch preferenceType {
        case .minValue:
            if weatherCharacteristic < preference {
                if preference == 0 {
                    penalty = floor(weatherCharacteristic / 10) < 2 ? Int(weatherCharacteristic / 10) : 2
                } else {
                    let deviation : Float = (preference - weatherCharacteristic) / preference
                    penalty = floor(deviation * 10) < 2 ? Int(floor(deviation * 10)) : 2
                }
            } else {
                penalty = 0
            }
        case .maxValue:
            if weatherCharacteristic > preference {
                if preference == 0 {
                    penalty = floor(weatherCharacteristic / 10) < 2 ? Int(weatherCharacteristic / 10) : 2
                } else {
                    let deviation : Float = Float((weatherCharacteristic - preference) / preference)
                    penalty = floor(deviation * 10) < 2 ? Int(floor(deviation * 10)) : 2
                }
            } else {
                penalty = 0
            }
        }
        
        return penalty
    }
}

extension MainInteractor: CLLocationManagerDelegate {
    //MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        openWeatherService?.weatherForCoordinates(latitude: Float(locValue.latitude), longitude: Float(locValue.longitude)) { (response, error) in
            guard let weather = response else {
                print("\(error?.localizedDescription)")
                return
            }
            //            print("\(response)")
            self.qualify(weather: weather)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
}

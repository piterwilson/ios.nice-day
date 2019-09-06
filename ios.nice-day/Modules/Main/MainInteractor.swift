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
    func encountered(error: Error)
}

enum MainInteractorError: Error {
    case NoInternetConnection
    case NoPermissionForLocationData
}

class MainInteractor: NSObject {
    var presenter: MainInteractorDelegate?
    private var openWeatherService: OpenWeatherService?
    private var locationManager: CLLocationManager?
    private var monitor: NWPathMonitor?
    
    var currentWeather: Weather?
    
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
        
        if let weather = currentWeather {
            qualify(weather: weather)
        } else {
            try? qualifyWeatherAtCurrentLocation()
        }
    }
    
    //MARK: - Qualifying weather
    
    func qualifyWeatherAtCurrentLocation() throws {
        guard let connectivityStatus = monitor?.currentPath.status, connectivityStatus == .satisfied else {
            //TODO: Tell the user there is no connection to the internet
            throw MainInteractorError.NoInternetConnection
        }
        
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager?.requestLocation()
        } else {
            throw MainInteractorError.NoPermissionForLocationData
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
        
        presenter?.qualified(weather: weather, score: weatherRating)
    }
    
    //Penalties are determined by how much the parameter deviates from the preferred parameter and is capped off on a maximum of 2
    private func determinePenalty(weatherCharacteristic: Float, preference: Float, preferenceType: PreferenceType) -> Int {
        guard preference != 0 else {
            return floor(weatherCharacteristic / 10) < 2 ? Int(weatherCharacteristic / 10) : 2
        }
        
        let penalty: Int
        switch preferenceType {
        case .minValue:
            penalty = weatherCharacteristic < preference ? Int((preference - weatherCharacteristic) / preference) : 0
        case .maxValue:
            penalty = weatherCharacteristic > preference ? Int((weatherCharacteristic - preference) / preference) : 0
        }
        
        let cappedPenalty = penalty <= 2 ? penalty : 2
        return cappedPenalty
    }
}

extension MainInteractor: CLLocationManagerDelegate {
    //MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        openWeatherService?.weatherForCoordinates(latitude: Float(locValue.latitude), longitude: Float(locValue.longitude)) { (response, error) in
            guard let weather = response else {
                if let error = error {
                    self.presenter?.encountered(error: error)
                }
                return
            }
            self.currentWeather = weather
            self.qualify(weather: weather)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        presenter?.encountered(error: error)
    }
    
}

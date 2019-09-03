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
    
}

class MainInteractor: NSObject {
    var presenter: MainInteractorDelegate?
    var openWeatherService: OpenWeatherService?
    var locationManager: CLLocationManager?
    var monitor: NWPathMonitor?
    
    override init() {
        super.init()
        startMonitoringInternetConnection()
    }
    
    private func startMonitoringInternetConnection() {
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
        monitor?.start(queue: queue)
    }
    
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
    
    //Temporary hardcoded preference
    let preferredMinTemp: Double = 18
    let preferredMaxTemp: Double = 27
    let preferredMaxHumidity: Double = 0.8
    let preferredMaxRainfall: Double = 0
    let preferredMaxWindSpeed: Double = 8
    let preferredMaxCloudiness: Double = 0.2
    
    private func qualify(weather: Weather) {
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
                    let deviation : Double = Double((weatherCharacteristic - preference) / preference)
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
                print("\(error)")
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

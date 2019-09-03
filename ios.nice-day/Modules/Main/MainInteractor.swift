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
            print("\(response)")
            print("\(error)")
        }
    }
}

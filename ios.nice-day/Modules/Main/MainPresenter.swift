//
//  MainPresenter.swift
//  ios.nice-day
//
//  Created by Frank van Boheemen on 03/09/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import Foundation

class MainPresenter {
    weak var viewController: MainViewController?
    var interactor: MainInteractor?
    var router: MainRouter?
}

extension MainPresenter: MainViewControllerDelegate {    
    //MARK: - MainViewControllerDelegate
    func viewDidLoad() {
        viewController?.populateUI(headerText: nil, weather: nil, preferences: interactor?.loadPreferences())
        refreshWeather()
    }
    
    func refreshWeather() {
        viewController?.populateUI(headerText: "Analysing weather...", weather: nil, preferences: nil)
        interactor?.qualifyWeatherAtCurrentLocation()
    }
    
    func changedPreference(characteristic: WeatherCharacteristic, newValue: Float) {
        interactor?.savePreference(characteristic: characteristic, newValue: newValue)
    }
}

extension MainPresenter: MainInteractorDelegate {
    func qualified(weather: Weather, score: Int) {
        let headerText: String
        
        switch score {
        case 1..<3:
            headerText = "The weather is abysmal... Better stay inside!"
        case 3..<6:
            headerText = "The weather is not that great... Could be worse, though!"
        case 6..<8:
            headerText = "The weather is alright. Not perfect, but definitely fine."
        case 8..<10:
            headerText = "The weather is pretty great!"
        case 10:
            headerText = "The weather is couldn't be better! Enjoy today!"
        default:
            return
        }
        
        viewController?.populateUI(headerText: headerText, weather: weather, preferences: nil)
    }

}

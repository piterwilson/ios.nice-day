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
        interactor?.qualifyWeatherAtCurrentLocation()
    }
}

extension MainPresenter: MainInteractorDelegate {
    func qualified(weather: Weather, score: Int) {
        viewController?.currentTempLabel.text = "\(floor(weather.temp))°"
        viewController?.currentHumidityLabel.text = "\(Int(weather.humidity * 100))%"
        if let rainfall = weather.rain {
            viewController?.currentRainfallLabel.text = "\(Int(rainfall)) mm"
        } else {
            viewController?.currentRainfallLabel.text = "--"
        }
        viewController?.currentWindSpeedLabel.text = "\(Int(weather.wind.speed)) m/s"
        if let cloudiness = weather.cloudiness {
            viewController?.currentCloudinessLabel.text = "\(Int(cloudiness * 100))%"
        } else {
            viewController?.currentCloudinessLabel.text = "--"
        }
        
        switch score {
        case 1..<3:
            viewController?.HeaderLabel.text = "The weather is abysmal... Better stay inside!"
        case 3..<5:
            viewController?.HeaderLabel.text = "The weather is not that great... Could be worse, though!"
        case 6..<8:
            viewController?.HeaderLabel.text = "The weather is alright. Not perfect, but definitely fine."
        case 9:
            viewController?.HeaderLabel.text = "The weather is pretty great!"
        case 10:
            viewController?.HeaderLabel.text = "The weather is couldn't be better! Enjoy today!"

        default:
            return
        }
    }

}

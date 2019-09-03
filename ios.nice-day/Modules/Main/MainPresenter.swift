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
    
}

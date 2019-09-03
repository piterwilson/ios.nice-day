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
    weak var interactor: MainInteractor?
    weak var router: MainRouter?
    
}

extension MainPresenter: MainViewControllerDelegate {
    
}

extension MainPresenter: MainInteractorDelegate {
    
}

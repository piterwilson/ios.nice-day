//
//  MainRouter.swift
//  ios.nice-day
//
//  Created by Frank van Boheemen on 03/09/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import UIKit

class MainRouter {
    class func createModule() -> UIViewController? {
        guard let viewController = mainstoryboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else { return nil }

        let presenter = MainPresenter()
        let interactor = MainInteractor()
        let router = MainRouter()
        
        viewController.delegate = presenter
        presenter.viewController = viewController
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        return viewController
    }
    
    static var mainstoryboard: UIStoryboard{
        return UIStoryboard(name:"Main",bundle: Bundle.main)
    }
    
    func presentAlert(message: String, viewController: UIViewController?) {
        let alert = UIAlertController(title: "Something went wrong...",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController?.present(alert, animated: true, completion:nil)
    }
}

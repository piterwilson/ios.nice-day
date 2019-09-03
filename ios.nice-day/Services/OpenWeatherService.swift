//
//  OpenWeatherService.swift
//  ios.nice-day
//
//  Created by Frank van Boheemen on 03/09/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class OpenWeatherService {
    private let urlScheme = "https"
    private let urlBase = "api.openweathermap.org"
    private let urlPath = "/data/2.5/weather"
    private let apiKey = "4d664c7f4176c7a3cc0dbcf5654158ad"
    
    func weatherForCoordinates(latitude: CGFloat = 52.37, longitude: CGFloat = 4.89, completion: @escaping (Any?, Error?) -> ()) {
        guard let url = URL.constructURL(scheme: urlScheme, host: urlBase, path: urlPath, queryItems: ["lon" : "\(longitude)", "lat" : "\(latitude)", "APPID" : "\(apiKey)"]) else { return }
                
        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success(let result):
                completion(result, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

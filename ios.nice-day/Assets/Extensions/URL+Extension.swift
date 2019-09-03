//
//  URL+Extension.swift
//  ios.nice-day
//
//  Created by Frank van Boheemen on 03/09/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import Foundation

extension URL {
    static func constructURL(scheme: String, host: String, path: String, queryItems: [String : String]) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = []
        for item in queryItems {
            components.queryItems?.append(URLQueryItem(name: item.key, value: item.value))
        }
        return components.url
    }    
}

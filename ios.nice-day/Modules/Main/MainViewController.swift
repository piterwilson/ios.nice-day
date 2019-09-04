//
//  MainViewController.swift
//  ios.nice-day
//
//  Created by Frank van Boheemen on 03/09/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import UIKit

protocol MainViewControllerDelegate {
    func viewDidLoad()
    func refreshWeather()
    func changedPreference(characteristic: WeatherCharacteristic, newValue: Float)
}

class MainViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBOutlet weak var currentTempImageView: UIImageView!
    @IBOutlet weak var currentTempLabel: UILabel!
    
    @IBOutlet weak var currentHumidityImageView: UIImageView!
    @IBOutlet weak var currentHumidityLabel: UILabel!
    
    @IBOutlet weak var currentRainfallImageView: UIImageView!
    @IBOutlet weak var currentRainfallLabel: UILabel!
    
    @IBOutlet weak var currentWindSpeedImageView: UIImageView!
    @IBOutlet weak var currentWindSpeedLabel: UILabel!
    
    @IBOutlet weak var currentCloudinessImageView: UIImageView!
    @IBOutlet weak var currentCloudinessLabel: UILabel!
    
    @IBOutlet weak var preferencesHeaderLabel: UILabel!
    
    @IBOutlet weak var tempHeaderLabel: UILabel!
    @IBOutlet weak var tempSlider: UISlider!
    @IBOutlet weak var tempValueLabel: UILabel!
    
    @IBOutlet weak var humidityHeaderLabel: UILabel!
    @IBOutlet weak var humiditySlider: UISlider!
    @IBOutlet weak var humidityValueLabel: UILabel!
    
    @IBOutlet weak var rainfallHeaderLabel: UILabel!
    @IBOutlet weak var rainfallSlider: UISlider!
    @IBOutlet weak var rainfallValueLabel: UILabel!
    
    @IBOutlet weak var windSpeedHeaderLabel: UILabel!
    @IBOutlet weak var windSpeedSlider: UISlider!
    @IBOutlet weak var windSpeedValueLabel: UILabel!
    
    @IBOutlet weak var cloudinessHeaderLabel: UILabel!
    @IBOutlet weak var cloudinessSlider: UISlider!
    @IBOutlet weak var cloudinessValueLabel: UILabel!
    
    var delegate: MainViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.viewDidLoad()
    }
    
    func populateUI(headerText: String?, weather: Weather?, preferences: Preferences?) {
        if let headerText = headerText {
            headerLabel.text = headerText
        }
        
        if let weather = weather {
            currentTempLabel.text = "\(floor(weather.temp))°"
            currentHumidityLabel.text = "\(Int(weather.humidity * 100))%"
            if let rainfall = weather.rain {
                currentRainfallLabel.text = "\(Int(rainfall)) mm"
            } else {
                currentRainfallLabel.text = "--"
            }
            currentWindSpeedLabel.text = "\(Int(weather.wind.speed)) m/s"
            if let cloudiness = weather.cloudiness {
                currentCloudinessLabel.text = "\(Int(cloudiness * 100))%"
            } else {
                currentCloudinessLabel.text = "--"
            }
        }
        
        if let preferences = preferences {
            tempSlider.value = preferences.temperature
            tempValueLabel.text = "\(Int(preferences.temperature))°"
            
            humiditySlider.value = preferences.humidity
            humidityValueLabel.text = "\(Int(preferences.humidity * 100))%"

            rainfallSlider.value = preferences.rainfall
            rainfallValueLabel.text = "\(Int(preferences.rainfall)) mm"
            
            windSpeedSlider.value = preferences.windSpeed
            windSpeedValueLabel.text = "\(Int(preferences.windSpeed)) m/s"
            
            cloudinessSlider.value = preferences.cloudiness
            cloudinessValueLabel.text = "\(Int(preferences.cloudiness * 100))%"
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        delegate?.refreshWeather()
    }
    
    @IBAction func preferenceChanged(_ sender: Any) {
        guard let sender = sender as? UISlider else { return }
        
        let characteristic: WeatherCharacteristic
        switch sender.tag {
        case 0:
            characteristic = .temperature
            tempValueLabel.text = "\(Int(sender.value))°"
        case 1:
            characteristic = .humidity
            humidityValueLabel.text = "\(Int(sender.value * 100))%"
        case 2:
            characteristic = .rainfall
            rainfallValueLabel.text = "\(Int(sender.value)) mm"
        case 3:
            characteristic = .windSpeed
            windSpeedValueLabel.text = "\(Int(sender.value)) m/s"
        case 4:
            characteristic = .cloudiness
            cloudinessValueLabel.text = "\(Int(sender.value * 100))%"
        default:
            print("Unknown characteristic changed")
            return
        }
        
        delegate?.changedPreference(characteristic: characteristic, newValue: sender.value)
    }
}

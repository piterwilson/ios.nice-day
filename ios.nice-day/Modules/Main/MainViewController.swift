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
    @IBOutlet weak var tempRangeSliderContainerView: UIView!
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
    private var tempRangeSlider: RangeSlider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutView()
        delegate?.viewDidLoad()
    }
    
    private func layoutView() {
        configureRangeSlider()
        
        humiditySlider.maximumTrackTintColor = UIColor(white: 0.9, alpha: 1)
        rainfallSlider.maximumTrackTintColor = UIColor(white: 0.9, alpha: 1)
        windSpeedSlider.maximumTrackTintColor = UIColor(white: 0.9, alpha: 1)
        cloudinessSlider.maximumTrackTintColor = UIColor(white: 0.9, alpha: 1)
    }
    
    
    private func configureRangeSlider() {
        let rangeSlider = RangeSlider()
        tempRangeSliderContainerView.addSubview(rangeSlider)
        rangeSlider.frame = tempRangeSliderContainerView.frame
        rangeSlider.center = tempRangeSliderContainerView.center
        rangeSlider.addTarget(self, action: #selector(preferenceChanged(_:)),
                              for: .valueChanged)
        tempRangeSlider = rangeSlider
    }
    
    func populateUI(headerText: String?, weather: Weather?, preferences: Preferences?) {
        if let headerText = headerText {
            UIView.transition(with: headerLabel,
                              duration: 0.25,
                              options: .transitionCrossDissolve,
                              animations: { [weak self] in
                                self?.headerLabel.text = headerText
                }, completion: nil)
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
            tempRangeSlider?.lowerValue = CGFloat(preferences.lowerTemperature / 40)
            tempRangeSlider?.upperValue = CGFloat(preferences.upperTemperature / 40)
            tempValueLabel.text = "\(Int(preferences.lowerTemperature)) - \(Int(preferences.upperTemperature))°"
            
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
        if let sender = sender as? UISlider {
            
            let characteristic: WeatherCharacteristic
            switch sender.tag {
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
            
        } else if let sender = sender as? RangeSlider {
            tempValueLabel.text = "\(Int(sender.lowerValue * 40)) - \(Int(sender.upperValue * 40))°"
            delegate?.changedPreference(characteristic: .lowerTemperature, newValue: Float(sender.lowerValue * 40))
            delegate?.changedPreference(characteristic: .upperTemperature, newValue: Float(sender.upperValue * 40))
        }
    }
}


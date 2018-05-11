//
//  ViewController.swift
//  WeatherApp
//
//  Created by Владислав Варфоломеев on 19.04.2018.
//  Copyright © 2018 Владислав Варфоломеев. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var apparentTemperatureLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        toggleActivityIndicator(on: true)
        getCurrenntWeatherData()
    }
    func toggleActivityIndicator(on: Bool) {
        refreshButton.isHidden = on
        if on {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    lazy var weatherManager = APIWeatherManager(apiKey: "48b9f4242edad61f8606988366ebb77b")
    let coordinates = Coordinates(latitude: 53.903766 , longitude: 27.554047) //координаты Минска
  
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrenntWeatherData()
    }
    
    
    func getCurrenntWeatherData()
    {
        weatherManager.fetchCurrentWeatherWith(coordinates: coordinates) { (result) in
            self.toggleActivityIndicator(on: false)
            
            switch result {
            case .Success(let currentWeather):
                self.updateUIWith(currentWeater: currentWeather)
            case .Failure(let error as NSError):
                
                let alertController = UIAlertController(title: "Unable to get data ", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    func updateUIWith(currentWeater: CurrentWeather) {
        self.imageView.image = currentWeater.icon
        self.pressureLabel.text = currentWeater.pressureString
        self.temperatureLabel.text = currentWeater.temperatureString
        self.apparentTemperatureLabel.text = currentWeater.apparentTemperatureString
        self.humidityLabel.text = currentWeater.humidityString
        
    }
    
    
    
}


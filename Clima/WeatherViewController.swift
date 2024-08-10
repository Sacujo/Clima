//
//  ViewController.swift
//  Clima
//
//  Created by Igor Guryan on 02.12.2023.
//

import UIKit
import SnapKit
import CoreLocation

let API_KEY = "2824da4b3326dd9fa64ec86f70988e13"

class WeatherViewController: UIViewController {
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        searchTextField.delegate = self
        weatherManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        setupView()
        setupLayout()
    }
    
    
    lazy var mainStack: UIStackView = {
        var stack = UIStackView()
//        stack.backgroundColor = .blue
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.distribution = .fill
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var searchStack: UIStackView = {
        var stack = UIStackView()
//        stack.backgroundColor = .yellow
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(locationButton)
        stack.addArrangedSubview(searchTextField)
        stack.addArrangedSubview(searchButton)
        return stack
    }()
    
    lazy var locationButton: UIButton = {
        var button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var searchTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "Search"
        textField.textAlignment = .right
        textField.minimumFontSize = 12
        textField.font = UIFont.systemFont(ofSize: 25)
        textField.clearButtonMode = .never
        textField.borderStyle = .roundedRect
        textField.contentMode = .scaleToFill
        textField.backgroundColor = .systemFill
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .go
        return textField
    }()
    
    lazy var searchButton: UIButton = {
        var button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .label
        button.contentMode = .scaleToFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var backgroundImage: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = .background
        return imageView
    }()
    
    lazy var conditionImage: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(systemName: "sun.max")
        imageView.tintColor = .label
        return imageView
    }()
    
    lazy var temperatureStack: UIStackView = {
        var stack = UIStackView()
        //        stack.backgroundColor = .yellow
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.contentMode = .scaleToFill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(tempCountLabel)
        stack.addArrangedSubview(degreeLabel)
        stack.addArrangedSubview(celciusLabel)
        return stack
    }()
    
    
    lazy var tempCountLabel: UILabel = {
        var label = UILabel()
        label.text = "21"
        label.font = UIFont.systemFont(ofSize: 80, weight: UIFont.Weight.black)
        label.contentMode = .right
        return label
    }()
    
    lazy var degreeLabel: UILabel = {
        var label = UILabel()
        label.text = "°"
        label.font = UIFont.systemFont(ofSize: 100, weight: UIFont.Weight.light)
        label.contentMode = .left
        return label
    }()
    
    lazy var celciusLabel: UILabel = {
        var label = UILabel()
        label.text = "C"
        label.font = UIFont.systemFont(ofSize: 100, weight: UIFont.Weight.light)
        label.contentMode = .left
        return label
    }()
    
    lazy var cityLabel: UILabel = {
        var label = UILabel()
        label.text = "London"
        label.font = UIFont.systemFont(ofSize: 30)
        label.contentMode = .left
        return label
    }()
    
    lazy var emptyView: UIView = {
        var view = UIView()
        return view
    }()
}
extension WeatherViewController {
    func setupView() {
        view.addSubview(backgroundImage)
        view.addSubview(mainStack)
        mainStack.addArrangedSubview(searchStack)
        mainStack.addArrangedSubview(conditionImage)
        mainStack.addArrangedSubview(temperatureStack)
        mainStack.addArrangedSubview(cityLabel)
        mainStack.addArrangedSubview(emptyView)
        
    }
    
    func setupLayout() {
        mainStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            
            
            
        }
        backgroundImage.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview()
            
        }
        
        searchStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        
        locationButton.snp.makeConstraints { make in
            make.size.width.height.equalTo(40)
        }
        
        searchButton.snp.makeConstraints { make in
            make.size.width.height.equalTo(40)
        }
        
        conditionImage.snp.makeConstraints { make in
            make.size.width.height.equalTo(120)
        }
        	
    }
}

//MARK: UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if searchTextField.text != "" {
            return true
        } else {
            searchTextField.placeholder = "Type Something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        searchTextField.text = ""
    }
    
    @objc func searchButtonTapped(sender: UIButton) {
        searchTextField.endEditing(true)
    }
}
//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.tempCountLabel.text = weather.temperatureString
            self.conditionImage.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}


//MARK: - SLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
    
    @objc func locationButtonTapped(sender: UIButton) {
        locationManager.requestLocation()
    }
}
                                        
                                        
#Preview{WeatherViewController()}


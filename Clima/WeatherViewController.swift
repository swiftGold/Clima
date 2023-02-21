//
//  ViewController.swift
//  Clima
//
//  Created by Сергей Золотухин on 15.02.2023.
//

import UIKit
import CoreLocation

final class WeatherViewController: UIViewController {
    
    private let backgoundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.tintColor = UIColor(named: "labelColor")
        button.setTitleColor(.green, for: .normal)
        button.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search"
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(-20, 0, 0)
        textField.delegate = self
        textField.textAlignment = .right
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = UIColor(named: "labelColor")
        button.setTitleColor(.green, for: .normal)
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let conditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "sun.max")
        imageView.contentMode = .scaleToFill
        imageView.tintColor = UIColor(named: "labelColor")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "labelColor")
        label.text = "00"
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 248), for: .horizontal)
        label.font = UIFont.boldSystemFont(ofSize: 80)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let degreeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "labelColor")
        label.text = "°"
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)
        label.font = UIFont.boldSystemFont(ofSize: 80)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let celsiusLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "labelColor")
        label.text = "C"
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        label.font = UIFont.boldSystemFont(ofSize: 80)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let temperatureStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "labelColor")
        label.textAlignment = .center
        label.text = "City name"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let hiddenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.alignment = .trailing
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var weatherManager = WeatherManager()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
    }

    @objc
    private func locationButtonTapped() {
        locationManager.requestLocation()
    }
    
    @objc
    private func searchButtonTapped() {
        searchTextField.endEditing(true)
        textFieldDidEndingEditing(searchTextField)
    }
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            weatherManager.fetchWeatherByCoordinates(lat: lat, long: long)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - UITextFieldDelegate
//теперь работает нажание "enter" на клавиатуре
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(searchTextField.text!)
        searchTextField.endEditing(true)
        textFieldDidEndingEditing(searchTextField)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    func didFailWithError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.locationLabel.text = "\(error)"
        }
    }
    
    func didUpdateWeatherVC(with model: WeatherModel) {
        DispatchQueue.main.async { [weak self] in
            self?.conditionImageView.image = UIImage(systemName: "\(model.conditionName)")
            self?.temperatureLabel.text = model.temperatureString
            self?.locationLabel.text = model.cityName
        }
    }
}

//MARK: - Private methods
private extension WeatherViewController {
    
    func textFieldDidEndingEditing(_ textField: UITextField) {
        if let city = textField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        textField.text = " "
    }
    
    func setupViewController() {
        addSubviews()
        setConstraints()
    }
    
    func addSubviews() {
        topStackView.addArrangedSubview(locationButton)
        topStackView.addArrangedSubview(searchTextField)
        topStackView.addArrangedSubview(searchButton)
        
        temperatureStackView.addArrangedSubview(temperatureLabel)
        temperatureStackView.addArrangedSubview(degreeLabel)
        temperatureStackView.addArrangedSubview(celsiusLabel)
        
        mainStackView.addArrangedSubview(topStackView)
        mainStackView.addArrangedSubview(conditionImageView)
        mainStackView.addArrangedSubview(temperatureStackView)
        mainStackView.addArrangedSubview(locationLabel)
        mainStackView.addArrangedSubview(hiddenView)
        
        view.addSubview(backgoundImageView)
        view.addSubview(mainStackView)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            backgoundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgoundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgoundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgoundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            topStackView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),
            topStackView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),

            
            locationButton.heightAnchor.constraint(equalToConstant: 40),
            locationButton.widthAnchor.constraint(equalToConstant: 40),
            
            searchButton.heightAnchor.constraint(equalToConstant: 40),
            searchButton.widthAnchor.constraint(equalToConstant: 40),
            
            conditionImageView.heightAnchor.constraint(equalToConstant: 120),
            conditionImageView.widthAnchor.constraint(equalToConstant: 120),
            
            temperatureStackView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor)
//            temperatureStackView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor)


        ])
    }
}




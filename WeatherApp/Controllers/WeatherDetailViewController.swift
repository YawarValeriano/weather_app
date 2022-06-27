//
//  WeatherDetailViewController.swift
//  WeatherApp
//
//  Created by admin on 6/23/22.
//

import UIKit
import SVProgressHUD

class WeatherDetailViewController: UIViewController {

    static let storyboardName = "WeatherDetail"
    static let identifier = "WeatherDetailViewController"
    
    var cityIdString: String?
    var cityWeather: CityWeather?
    
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var minExpectedLabel: UILabel!
    @IBOutlet weak var maxExpectedLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var cloudsLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var timezoneLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var lonLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cityId = cityIdString {
            guard let url = URL(string: "https://openweathermap.org/data/2.5/weather?id=\(cityId)&appid=439d4b804bc8187953eb36d2a8c26a02") else { return }
            loadCityCurrentWeather(url)
        }
    }
    
    private func loadCityCurrentWeather(_ url: URL) {
        SVProgressHUD.show()
        NetworkManager.shared.get(CityWeatherByID.self, from: url) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(let data):
                self.setValuesFromData(data: data)
            case .failure(let error):
                self.showError(withDescription: error.localizedDescription)
            }
        }
    }
    
    private func setValuesFromData(data: CityWeatherByID) {
        let weatherInfo = data.weather[0]
        country.text = "Country: \(data.sys.country)"
        if let flagUrl = URL(string: "https://countryflagsapi.com/png/\(data.sys.country)") {
            flagImage.image = ImageManager.shared.getUIImage(formURL: flagUrl)
        }
        if let iconUrl = URL(string: "https://openweathermap.org/img/wn/\(weatherInfo.icon)@4x.png") {
            weatherImage.image = ImageManager.shared.getUIImage(formURL: iconUrl)
        }
        cityLabel.text = data.name
        statusLabel.text = "\(weatherInfo.main), \(weatherInfo.weatherDescription)"
        temperatureLabel.text = "Temperature: \(data.main.temp) ºC"
        feelsLikeLabel.text = "Feels like: \(data.main.feelsLike) ºC"
        minExpectedLabel.text = "Min expected: \(data.main.tempMin) ºC"
        maxExpectedLabel.text = "Max expected: \(data.main.tempMax) ºC"
        pressureLabel.text = "Pressure: \(data.main.pressure) hPa"
        humidityLabel.text = "Humidity: \(data.main.humidity)%"
        windLabel.text = "Wind: \(tranformWindToString(data.wind))"
        visibilityLabel.text = "Visibility: \(data.visibility / 1000)Km"
        cloudsLabel.text = "Clouds: \(data.clouds.all)%"
        currentTimeLabel.text = "Time: \(convertUTCToString(data.dt))"
        sunriseLabel.text = "Sunrise: \(convertUTCToString(data.sys.sunrise))"
        sunsetLabel.text = "Sunset: \(convertUTCToString(data.sys.sunset))"
        timezoneLabel.text = "Timezone: \(convertToUTCTimezone(data.timezone))"
        latLabel.text = "Lat: \(data.coord.lat)"
        lonLabel.text = "Lon: \(data.coord.lon)"
    }
    
    private func tranformWindToString(_ wind: Wind) -> String {
        let compassDirection = [ "N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW","N" ]
        let result = round(Double(wind.deg % 360)/22.5)
        return "\(wind.speed) \(compassDirection[Int(result)])"
    }
    
    private func convertToUTCTimezone(_ seconds: Int) -> String {
        let sign = seconds < 0 ? " -" : " +"
        let hours = seconds / 3600
        return "UTC\(sign)\(abs(hours))"
    }
    
    private func convertUTCToString(_ utc: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(utc))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    
        
    }
    
    private func showError(withDescription error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            print("OK")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

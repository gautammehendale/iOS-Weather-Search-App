import Foundation
import Combine
import Alamofire

class WeatherViewModel: ObservableObject {
    private let weatherService = WeatherService()
    @Published var weatherData: WeatherData = WeatherData.default
    @Published var dailyWeather: [DailyWeather] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var currentTemperature: Int = 0
    @Published var currentWeatherText: String = ""
    @Published var cityName: String = ""
    @Published var weatherIcon: String = ""
    @Published var humidity: Double = 0
    @Published var windSpeed: Double = 0
    @Published var visibility: Double = 0
    @Published var pressure: Double = 0
    @Published var precipitation: Double = 0 
    @Published var cloudCover: Double = 0
    @Published var uvIndex: Double = 0
    @Published var currentTemperature1: Int = 0
    

    private let weatherCodeMapping: [Int: (icon: String, description: String)] = [
        1000: ("sun.max", "Clear"),
        1100: ("cloud.sun", "Mostly Clear"),
        1101: ("cloud.sun.fill", "Partly Cloudy"),
        1102: ("cloud", "Mostly Cloudy"),
        1001: ("cloud", "Cloudy"),
        2000: ("cloud.fog", "Fog"),
        2100: ("cloud.fog", "Light Fog"),
        4000: ("cloud.drizzle", "Drizzle"),
        4001: ("cloud.rain", "Rain"),
        4200: ("cloud.rain.fill", "Light Rain"),
        4201: ("cloud.heavyrain", "Heavy Rain"),
        5000: ("snow", "Snow"),
        5001: ("cloud.snow", "Flurries"),
        5100: ("cloud.snow.fill", "Light Snow"),
        5101: ("cloud.snow.fill", "Heavy Snow"),
        6000: ("cloud.hail", "Freezing Drizzle"),
        6001: ("cloud.hail.fill", "Freezing Rain"),
        6200: ("cloud.sleet", "Light Freezing Rain"),
        6201: ("cloud.sleet.fill", "Heavy Freezing Rain"),
        7000: ("cloud.sleet", "Ice Pellets"),
        7101: ("cloud.sleet.fill", "Heavy Ice Pellets"),
        7102: ("cloud.sleet.fill", "Light Ice Pellets"),
        8000: ("cloud.bolt", "Thunderstorm")
    ]

    func fetchWeather(latitude: Double, longitude: Double) {
        isLoading = true
        fetchCityName(latitude: latitude, longitude: longitude)

        weatherService.fetchDailyWeather(lat: "\(latitude)", lng: "\(longitude)") { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let weather):
                    self.dailyWeather = weather
                    if let currentWeather = weather.first {
                        self.currentTemperature1 = Int(currentWeather.temperatureApparent)
                        self.currentTemperature = Int(currentWeather.temperatureMax)
                        self.humidity = currentWeather.humidity
                        self.windSpeed = currentWeather.windSpeed
                        self.visibility = currentWeather.visibility
                        self.pressure = currentWeather.pressureSeaLevel
                        self.precipitation = currentWeather.precipitation
                        self.cloudCover = currentWeather.cloudCover
                        self.uvIndex = (currentWeather.uvIndex as? Double) ?? 0
                        self.currentWeatherText = self.getWeatherDescription(for: currentWeather.weatherCode)
                        self.weatherIcon = self.getWeatherIcon(for: currentWeather.weatherCode)
                        self.weatherData = WeatherData(cityName: "Los Angeles", temperatureApparent: currentWeather.temperatureApparent, temperatureMax: currentWeather.temperatureMax, temperatureMin: currentWeather.temperatureMin, humidity: currentWeather.humidity, windSpeed: currentWeather.windSpeed, visibility: currentWeather.visibility, pressureSeaLevel: currentWeather.pressureSeaLevel, cloudCover: currentWeather.cloudCover, precipitation: currentWeather.precipitation, uvIndex: currentWeather.uvIndex ?? 0.0, latitude: 0.0, longitude: 0.0, dailyWeather: weather, weatherCode: currentWeather.weatherCode)
                        
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func getWeatherDescription(for code: Int) -> String {
        return weatherCodeMapping[code]?.description ?? "Unknown"
    }

    private func getWeatherIcon(for code: Int) -> String {
        return weatherCodeMapping[code]?.icon ?? "questionmark"
    }

    private func fetchCityName(latitude: Double, longitude: Double) {
        let geocodeURL = "https://maps.googleapis.com/maps/api/geocode/json"
        let apiKey = "AIzaSyACRIoC8AhJKRjT0q3hVKJlHr4ah1P-yp8"

        let parameters: [String: Any] = [
            "latlng": "\(latitude),\(longitude)",
            "key": apiKey
        ]
        AF.request(geocodeURL, method: .get, parameters: parameters).validate().responseDecodable(of: GeocodeResponse.self) { response in
            switch response.result {
            case .success(let geocodeData):
                if let firstResult = geocodeData.results.first { 
                    if let city = self.extractCity(from: firstResult.addressComponents) {
                        DispatchQueue.main.async {
                            self.cityName = city
                        }
                    } else {
                        print("City could not be found.")
                    }
                } else {
                    print("No results found.")
                }
            case .failure(let error):
                print("Error fetching the city name: \(error.localizedDescription)")
                print("There was an error")
            }
        }
    }

    private func extractCity(from components: [AddressComponent]) -> String? {
        for component in components {
            if component.types.contains("locality") {
                return component.longName
            }
        }
        return nil
    }

}

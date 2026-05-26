import Foundation

struct DailyWeather: Identifiable, Codable {
    var id = UUID()
    let date: String
    let temperatureApparent: Double
    let temperatureMax: Double
    let temperatureMin: Double
    let sunrise: String
    let sunset: String
    let humidity: Double
    let windSpeed: Double
    let visibility: Double
    let pressureSeaLevel: Double
    let precipitation: Double
    let cloudCover: Double
    let uvIndex: Double?
    let weatherCode: Int

    init?(from dictionary: [String: Any]) {
        guard
            let startTime = dictionary["startTime"] as? String,
            let values = dictionary["values"] as? [String: Any],
            let temperatureApparent = values["temperatureApparent"] as? Double,
            let temperatureMax = values["temperatureMax"] as? Double,
            let temperatureMin = values["temperatureMin"] as? Double,
            let sunrise = values["sunriseTime"] as? String,
            let sunset = values["sunsetTime"] as? String,
            let humidity = values["humidity"] as? Double,
            let windSpeed = values["windSpeed"] as? Double,
            let visibility = values["visibility"] as? Double,
            let pressureSeaLevel = values["pressureSeaLevel"] as? Double,
            let precipitation = values["precipitationProbability"] as? Double,
            let cloudCover = values["cloudCover"] as? Double,
            let weatherCode = values["weatherCode"] as? Int
        else {
            return nil
        }
        
        self.date = startTime
        self.temperatureApparent = temperatureApparent
        self.temperatureMax = temperatureMax
        self.temperatureMin = temperatureMin
        self.sunrise = sunrise
        self.sunset = sunset
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.visibility = visibility
        self.pressureSeaLevel = pressureSeaLevel
        self.precipitation = precipitation
        self.cloudCover = cloudCover
        self.uvIndex = values["uvIndex"] as? Double  
        self.weatherCode = weatherCode
    }
}

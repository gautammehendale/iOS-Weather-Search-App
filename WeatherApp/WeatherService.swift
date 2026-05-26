import Foundation
import Alamofire

struct WeatherService {
    private let baseURL = "https://webtech3backend-441321.uw.r.appspot.com/weatherdata"

    func fetchDailyWeather(lat: String, lng: String, completion: @escaping (Result<[DailyWeather], Error>) -> Void) {
        let urlString = "\(baseURL)?lat=\(lat)&lng=\(lng)"
        print("Fetching daily weather data from the: \(urlString)")

        AF.request(urlString, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let timelines = json["data"] as? [String: Any],
                   let dailyData = timelines["timelines"] as? [[String: Any]] {
                    
                    print("Number of Timelines: \(dailyData.count)")
                    
                    var parsedWeather: [DailyWeather] = []

                    if let firstTimeline = dailyData.first,
                       let intervals = firstTimeline["intervals"] as? [[String: Any]] {
                        print("Total Intervals in First Timeline: \(intervals.count)")
                        
                        for interval in intervals {
                            if let weather = DailyWeather(from: interval) {
                                parsedWeather.append(weather)
                            }
                        }
                    }
                    
                    completion(.success(parsedWeather))
                    print("Parsed Weather Count: \(parsedWeather.count)")
                } else {
                    print("Failed to parse the JSON content")
                    completion(.failure(NSError(domain: "InvalidJSON", code: -1, userInfo: nil)))
                }
            case .failure(let error):
                print("Network Request Failed: \(error)")
                completion(.failure(error))
            }
        }
    }

    func fetchFullWeather(lat: String, lng: String, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let urlString = "\(baseURL)?lat=\(lat)&lng=\(lng)&include=current"
        print("Fetching full weather data from x: \(urlString)")

        AF.request(urlString, method: .get).validate().responseDecodable(of: WeatherData.self) { response in
            switch response.result {
            case .success(let weatherData):
                completion(.success(weatherData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

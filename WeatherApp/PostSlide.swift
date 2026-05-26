import SwiftUI
import Toast

struct PostSlideView: View {
    @Binding var cityData: WeatherData
    @Environment(\.presentationMode) var presentationMode
    @State private var isFavorite: Bool = false
    @State private var favorites: [WeatherData] = []
    
    var onDismiss: (() -> Void)?

    var body: some View {
        ZStack(alignment: .top) {

            Image("App_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                HStack {

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        onDismiss?()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundColor(.blue)
                            Text("Weather")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.leading, 30)

                    Spacer()

                    Text(cityData.cityName)
                        .font(.headline)
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: {
                        let city = cityData.cityName
                        let temperature = String(format: "%.0f", cityData.temperatureApparent)
                        let conditions = cityData.weatherText()
                        openTwitter(city: city, temperature: temperature, conditions: conditions)
                    }) {
                        Image("twitter")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                    }
                    .padding(.trailing, 30)
                }
                .padding(.horizontal)
                .frame(height: 50)
                .background(Color.white)
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20)
            }
            .edgesIgnoringSafeArea(.top)

            VStack(spacing: 20) {
                
                Spacer()

                ZStack {
                    NavigationLink(
                        destination: WeatherDetailsView(cityData: cityData)
                    ) {
                        FirstSubView(
                            temperature: Int(cityData.temperatureApparent),
                            weatherText: cityData.weatherText(),
                            cityName: cityData.cityName,
                            weatherIcon: cityData.weatherIcon()
                        )
                    }
                    
                    .frame(width: 400)
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)

                    HStack {
                        Spacer()
                        Button(action: {
                                                    if isFavorite {
                                                        removeFromFavorites()
                                                        showToastWithMessage("\(cityData.cityName) was removed from the \nFavorite List")
                                                    } else {
                                                        addToFavorites()
                                                        showToastWithMessage("\(cityData.cityName) was added to the Favorite List")
                                                    }
                                                })
                        {
                            ZStack {
                               
                                Image(isFavorite ? "close-circle" : "plus-circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(.trailing, 60)
                        .offset(y: -100)
                    }
                }
                .padding(.top, -30)
                .padding(.bottom, 20)

                SecondSubView(
                    humidity: cityData.humidity,
                    windSpeed: cityData.windSpeed,
                    visibility: cityData.visibility,
                    pressure: cityData.pressureSeaLevel
                )
                .padding(.horizontal, 20)
                .frame(height: 120)
                .padding(.bottom, 20)

                ThirdSubView(dailyWeather: cityData.dailyWeather)
                    .padding(.horizontal, 25)
                    .frame(height: 250)

                Spacer()
            }
            .padding(.top, 15)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            checkIfFavorite()
            loadFavorites()
        }
        
    }
    private func showToastWithMessage(_ message: String) {
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.view.makeToast(
                message,
                duration: 1.0,
                position: .bottom
            )
        }
    }


    private func addToFavorites() {
        if !favorites.contains(where: { $0.cityName == cityData.cityName }) {
            favorites.append(cityData)
            saveFavorites()
        }
        isFavorite = true
        print("Already there")
    }

    private func removeFromFavorites() {
        favorites.removeAll { $0.cityName == cityData.cityName }
        saveFavorites()
        isFavorite = false
        print("It is now removed")
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: "FavoriteCities")
            print("Saved here")
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: "FavoriteCities"),
           let loadedFavorites = try? JSONDecoder().decode([WeatherData].self, from: data) {
            favorites = loadedFavorites
            print("Loaded in the favorites")
        }
    }

    private func checkIfFavorite() {
        isFavorite = favorites.contains(where: { $0.cityName == cityData.cityName })
    }
    private func openTwitter(city: String, temperature: String, conditions: String) {
        let tweetText = "The current temperature at \(city) is \(temperature)°F. The weather conditions are \(conditions)"
        guard let encodedTweetText = tweetText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedTweetText)") else {
            print("Error encoding the tweet text.")
            return
        }
        UIApplication.shared.open(url)
    }
}

struct FavoriteWeatherTab: View {
    let weatherData: WeatherData

    var body: some View {
        VStack {
            Text(weatherData.cityName)
                .font(.headline)
            Text("\(Int(weatherData.temperatureApparent))°F")
                .font(.subheadline)
        }
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(8)
    }
}


extension WeatherData {
    func weatherText() -> String {
        
        let weatherTextMapping: [Int: String] = [
            1000: "Clear",
            1100: "Mostly Clear",
            1101: "Partly Cloudy",
            1102: "Mostly Cloudy",
            1001: "Cloudy",
            2000: "Fog",
            2100: "Light Fog",
            4000: "Drizzle",
            4001: "Rain",
            4200: "Light Rain",
            4201: "Heavy Rain",
            5000: "Snow",
            5001: "Flurries",
            5100: "Light Snow",
            5101: "Heavy Snow",
            6000: "Freezing Drizzle",
            6001: "Freezing Rain",
            6200: "Light Freezing Rain",
            6201: "Heavy Freezing Rain",
            7000: "Ice Pellets",
            7101: "Heavy Ice Pellets",
            7102: "Light Ice Pellets",
            8000: "Thunderstorm"
        ]
        return weatherTextMapping[weatherCode] ?? "Unknown"
    }

    func weatherIcon() -> String {
        let weatherIconMapping: [Int: String] = [
            0: "Unknown",
            1000: "Clear",
            1100: "Mostly Clear",
            1101: "Partly Cloudy",
            1102: "Mostly Cloudy",
            1001: "Cloudy",
            2000: "Fog",
            2100: "Light Fog",
            4000: "Drizzle",
            4001: "Rain",
            4200: "Light Rain",
            4201: "Heavy Rain",
            5000: "Snow",
            5001: "Flurries",
            5100: "Light Snow",
            5101: "Heavy Snow",
            6000: "Freezing Drizzle",
            6001: "Freezing Rain",
            6200: "Light Freezing Rain",
            6201: "Heavy Freezing Rain",
            7000: "Ice Pellets",
            7101: "Heavy Ice Pellets",
            7102: "Light Ice Pellets",
            8000: "Thunderstorm"
        ]
        return weatherIconMapping[weatherCode] ?? "questionmark"
    }
}

struct WeatherData: Codable {
    var cityName: String
    var temperatureApparent: Double
    var temperatureMax: Double
    var temperatureMin: Double
    var humidity: Double
    var windSpeed: Double
    var visibility: Double
    var pressureSeaLevel: Double
    var cloudCover: Double
    var precipitation: Double
    var uvIndex: Double
    var latitude: Double
    var longitude: Double
    var dailyWeather: [DailyWeather]
    var weatherCode: Int

    static var `default`: WeatherData {
        WeatherData(
            cityName: "Default City",
            temperatureApparent: 25.0,
            temperatureMax: 25.0,
            temperatureMin: 15.0,
            humidity: 50.0,
            windSpeed: 10.0,
            visibility: 10.0,
            pressureSeaLevel: 1013.0,
            cloudCover: 40.0,
            precipitation: 20.0,
            uvIndex: 5.0,
            latitude: 0.0,
            longitude: 0.0,
            dailyWeather: [],
            weatherCode: 1000
        )
    }
}

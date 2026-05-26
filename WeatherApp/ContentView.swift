import SwiftUI
import Alamofire
import SwiftSpinner
import Toast

struct ContentView: View {
    @State private var isTransitioning = false
    @State private var cityName: String = ""
    @State private var citySuggestions: [CitySuggestion] = []
    @State private var showSuggestions = false
    @State private var selectedCityWeather: WeatherData?
    @State private var favorites: [WeatherData] = []
    @State private var selectedPage = 0
    @ObservedObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var shouldNavigate: Bool = false
    @State private var isLoading = true
    
    
    var body: some View {
        Group {
            if isTransitioning {
                NavigationView {
                    ZStack(alignment: .top) {
                        Image("App_background")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                        if isLoading {
                                                ZStack {
                                                    Color.black.opacity(0.4)
                                                        .edgesIgnoringSafeArea(.all)
                                                }
                                                .onAppear {
                                                    SwiftSpinner.show("Fetching Weather Details for the current location")
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                        SwiftSpinner.hide()
                                                        isLoading = false
                                                    }
                                                }
                                            }                      else{
                            
                            
                            
                            
                            TabView(selection: $selectedPage) {
                                
                                VStack(spacing: 20) {
                                    if selectedPage == 0 {
                                        NavigationLink(
                                            destination: WeatherDetailsView(cityData: weatherViewModel.weatherData)
                                        ) {
                                            FirstSubView(
                                                temperature: weatherViewModel.currentTemperature,
                                                weatherText: weatherViewModel.currentWeatherText,
                                                cityName: weatherViewModel.cityName,
                                                weatherIcon: weatherViewModel.weatherIcon
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .onAppear {
                                            if let lat = locationManager.latitude, let lng = locationManager.longitude {
                                                print("Fetching updated weather data on FirstSubView render")
                                                weatherViewModel.fetchWeather(latitude: lat, longitude: lng)
                                            }
                                        }
                                        
                                        SecondSubView(
                                            humidity: weatherViewModel.humidity,
                                            windSpeed: weatherViewModel.windSpeed,
                                            visibility: weatherViewModel.visibility,
                                            pressure: weatherViewModel.pressure
                                        )
                                        
                                        ThirdSubView(dailyWeather: weatherViewModel.dailyWeather)
                                    } else if favorites.indices.contains(selectedPage - 1) {
                                        
                                        let favoriteWeather = favorites[selectedPage - 1]
                                        ZStack(alignment: .topTrailing) {
                                            NavigationLink(
                                                destination: WeatherDetailsView(cityData: favoriteWeather)
                                            ) {
                                                FavoriteContentView(weatherData: favoriteWeather)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            
                                            
                                            
                                            Button(action: {
                                                removeFavorite(at: selectedPage - 1)
                                            }) {
                                                
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .tag(0)
                                
                                
                                ForEach(favorites.indices, id: \.self) { index in
                                    VStack(spacing: 20) {
                                        let favoriteWeather = favorites[index]
                                        ZStack(alignment: .topTrailing) {
                                            NavigationLink(
                                                destination: WeatherDetailsView(cityData: favoriteWeather)
                                            ) {
                                                FavoriteContentView(weatherData: favoriteWeather)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            
                                            
                                            Button(action: {
                                                removeFavorite(at: selectedPage - 1)
                                            }) {
                                                Image("close-circle")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.white)
                                                    .background(Color.clear)
                                                    .padding([.top, .leading], 16)
                                                    .offset(x: -36, y: -36)
                                                    .zIndex(1)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .tag(index + 1)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .onAppear {
                                if favorites.isEmpty {
                                    selectedPage = 0
                                }
                                loadFavorites()
                            }
                            .onAppear {
                                if let lat = locationManager.latitude, let lng = locationManager.longitude {
                                    weatherViewModel.fetchWeather(latitude: lat, longitude: lng)
                                }
                                print("selectedcityweather: \(selectedCityWeather)")
                                loadFavorites()
                            }
                            .onChange(of: selectedPage) { newValue in
                                print("Switched to page: \(newValue)")
                            }
                            
                            
                            VStack(spacing: 0) {
                                searchBarView()
                                if showSuggestions {
                                    suggestionListView()
                                }
                            }
                            .background(Color.white.opacity(0.9))
                            .zIndex(3)
                        }
                    }
                }
            } else {
                SplashScreenView()
            }
        }
        .onAppear {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isTransitioning = true
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isLoading = true
                    }
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isLoading = false
                        }
                    }
                }
            }
        }
    }


    private func searchBarView() -> some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Enter City Name", text: $cityName)
                    .onChange(of: cityName, perform: handleCityNameChange)
                    .foregroundColor(.black)
                if !cityName.isEmpty {
                    Button(action: {
                        cityName = ""
                        citySuggestions = []
                        showSuggestions = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(8)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    private func suggestionListView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(citySuggestions) { suggestion in
                    navigationLinkForSuggestion(suggestion)
                    Divider()
                }
            }
        }
        .frame(maxHeight: 200)
        .background(Color.white.opacity(0.01))
        .cornerRadius(8)
        .padding(.horizontal)
        .zIndex(2)
        
    }

    private func navigationLinkForSuggestion(_ suggestion: CitySuggestion) -> some View {
        HStack {
            Button(action: {
                self.cityName = suggestion.mainText
                fetchWeatherForSuggestion(suggestion)
            }) {
                HStack(spacing:15) {
                    Text(suggestion.mainText) // City
                        .font(.headline)
                        .foregroundColor(.black)
                    if let state = suggestion.secondaryText, !state.isEmpty {
                        Text(state) // State
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            Spacer()
        }
        .background(
            NavigationLink(
                destination: PostSlideView(
                    cityData: .constant(selectedCityWeather ?? WeatherData.default),
                    onDismiss: {
                        cityName = ""
                        citySuggestions = []
                        showSuggestions = false
                    }
                ),
                isActive: $shouldNavigate,
                label: {
                    EmptyView()
                }
            )
            .hidden()
        )
    }

    private func handleCityNameChange(_ newValue: String) {
        if !newValue.isEmpty {
            fetchCitySuggestions(for: newValue)
        } else {
            citySuggestions = []
            showSuggestions = false
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: "FavoriteCities"),
           let loadedFavorites = try? JSONDecoder().decode([WeatherData].self, from: data) {
            favorites = loadedFavorites
        }
    }

    private func fetchCitySuggestions(for input: String) {
        guard !input.isEmpty, let encodedInput = input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let url = "https://webtech3backend-441321.uw.r.appspot.com/api/autocomplete?input=\(encodedInput)"
        print("Fetching city suggestions with URL: \(url)")
        AF.request(url, method: .get).validate().responseDecodable(of: [CitySuggestion].self) { response in
            switch response.result {
            case .success(let suggestions):
                DispatchQueue.main.async {
                    self.citySuggestions = suggestions.filter { !$0.mainText.isEmpty }
                    self.showSuggestions = !suggestions.isEmpty
                    print("Suggestions fetched: \(suggestions)")
                }
            case .failure(let error):
                print("Error fetching suggestions: \(error.localizedDescription)")
            }
        }
    }
    private func removeFavorite(at index: Int) {
        guard index >= 0 && index < favorites.count else { return }

        let removedCity = favorites[index].cityName
        favorites.remove(at: index)
        saveFavorites()

        if favorites.isEmpty {
            
            selectedPage = 0
        } else if selectedPage >= favorites.count {
            
            selectedPage = max(favorites.count - 1, 0)
        }

        showToastWithMessage("\(removedCity) was removed from the \nFavorite List")
    }
    private func saveFavorites() {
        
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: "FavoriteCities")
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
    //ChatGPT From Here
    private func fetchWeatherForSuggestion(_ suggestion: CitySuggestion) {
        print("Fetching coordinates for city: \(suggestion.mainText)")
        SwiftSpinner.show("Fetching Weather Details for \(cityName)")
        let geocodeURL = "https://maps.googleapis.com/maps/api/geocode/json"
        let apiKey = "AIzaSyACRIoC8AhJKRjT0q3hVKJlHr4ah1P-yp8"
        let address = suggestion.mainText

        AF.request(geocodeURL, method: .get, parameters: ["address": address, "key": apiKey])
            .validate()
            .responseDecodable(of: GeocodeResponse.self) { response in
                switch response.result {
                case .success(let geocodeData):
                    if let location = geocodeData.results.first?.geometry.location { //ChatGPT Till Here
                        self.fetchWeather(lat: location.lat, lng: location.lng) { dailyWeather in
                            self.selectedCityWeather = WeatherData(
                                cityName: self.cityName,
                                temperatureApparent: dailyWeather.first?.temperatureApparent ?? 0.0,
                                temperatureMax: dailyWeather.first?.temperatureMax ?? 0.0,
                                temperatureMin: dailyWeather.first?.temperatureMin ?? 0.0,
                                humidity: dailyWeather.first?.humidity ?? 0.0,
                                windSpeed: dailyWeather.first?.windSpeed ?? 0.0,
                                visibility: dailyWeather.first?.visibility ?? 0.0,
                                pressureSeaLevel: dailyWeather.first?.pressureSeaLevel ?? 0.0,
                                cloudCover: dailyWeather.first?.cloudCover ?? 0.0,
                                precipitation: dailyWeather.first?.precipitation ?? 0.0,
                                uvIndex: dailyWeather.first?.uvIndex ?? 0.0,
                                latitude: location.lat,
                                longitude: location.lng,
                                dailyWeather: dailyWeather,
                                weatherCode: dailyWeather.first?.weatherCode ?? 1000
                            )
                            self.shouldNavigate = true
                        }
                    }
                case .failure(let error):
                    print("Error fetching geocode data: \(error.localizedDescription)")
                }
            }
    }
    //ChatGPT From Here
    private func fetchWeather(lat: Double, lng: Double, completion: @escaping ([DailyWeather]) -> Void) {
        SwiftSpinner.show("Fetching Weather Details for \(cityName)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                SwiftSpinner.hide()
            }
        let weatherService = WeatherService()
        weatherService.fetchDailyWeather(lat: "\(lat)", lng: "\(lng)") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let dailyWeather):
                    print("Daily Weather Count: \(dailyWeather.count)")
                                    print("Daily Weather Details: \(dailyWeather)")
                    completion(dailyWeather)
                    print("dailyyy \(dailyWeather)")
                case .failure(let error):
                    print("Error fetching weather data: \(error.localizedDescription)")
                    completion([]) //ChatGPT Till Here
                }
            }
        }
    }
}

struct FavoriteContentView: View {
    let weatherData: WeatherData

    var body: some View {
        VStack(spacing: 20) {
            FirstSubView(
                temperature: Int(weatherData.temperatureApparent),
                weatherText: weatherData.weatherText(),
                cityName: weatherData.cityName,
                weatherIcon: weatherData.weatherIcon()
            )
            .frame(width: 400)
            
            .padding(.horizontal, 20)

            SecondSubView(
                humidity: weatherData.humidity,
                windSpeed: weatherData.windSpeed,
                visibility: weatherData.visibility,
                pressure: weatherData.pressureSeaLevel
            )
            ThirdSubView(dailyWeather: weatherData.dailyWeather)
        }
    }
}

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Image("App_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                Image("Mostly Clear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .offset(y: -350)
                    .padding(.bottom, 10)

                HStack {
                    Image("Powered_by_Tomorrow-Black")
                        .resizable()
                        .scaledToFit()
                        .offset(y: -100)
                        .frame(height: 23)
                }
                .padding(.bottom, 20)
            }
        }
    }
}


struct FirstSubView: View {
    let temperature: Int
    let weatherText: String
    let cityName: String
    let weatherIcon: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.3))
                .frame(height: 150)
                .shadow(radius: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white, lineWidth: 0.8)
                        )

            HStack {
                
                Image(weatherText)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 140)
                    .padding(.leading, -20)

                VStack(alignment: .leading, spacing: 10) {
                    Text("\(temperature)°F")
                        .font(.title2)
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(weatherText)
                        .font(.headline)

                    Text(cityName)
                        .font(.title2)
                        .fontWeight(.bold)
                        
                }

                Spacer()
            }
            .padding()
        }
        .padding(.horizontal, 15)
    }
}

struct SecondSubView: View {
    let humidity: Double
    let windSpeed: Double
    let visibility: Double
    let pressure: Double

    var body: some View {
        HStack(spacing: 35) {
            VStack(spacing: 10) {
                Text("Humidity")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                Image("Humidity")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("\(humidity, specifier: "%.0f") %")
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                Text("Wind Speed")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                Image("WindSpeed")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("\(windSpeed, specifier: "%.2f") mph")
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                Text("Visibility")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                Image("Visibility")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("\(visibility, specifier: "%.2f") mi")
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                Text("Pressure")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                Image("Pressure")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text("\(pressure, specifier: "%.0f") inHg")
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

struct ThirdSubView: View {
    let dailyWeather: [DailyWeather]

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(dailyWeather) { day in
                        WeatherRow(day: day, isLastRow: day.id == dailyWeather.last?.id)
                    }
                }
            }
            .background(Color.white.opacity(0.5))
            .cornerRadius(8)
            .padding(.horizontal, 35)
            .frame(width: 440, height: 237)
        }
    }
}

struct WeatherRow: View {
    let day: DailyWeather
    let isLastRow: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                
                Text(formatDate(day.date))
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(day.weatherCodeImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)

                HStack(spacing: 5) {
                    Text(formatToAMPM(day.sunrise))
                    .font(.subheadline)
                    Image("sun-rise")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                
                HStack(spacing: 5) {
                    Text(formatToAMPM(day.sunset))
                    .font(.subheadline)
                    Image("sun-set")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.3))

            if !isLastRow {
                Divider()
                    .background(Color.black.opacity(0.3))
                    .padding(.horizontal, 20)
            }
        }
    }

    private func formatDate(_ date: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MM/dd/yyyy"

        if let formattedDate = inputFormatter.date(from: date) {
            return outputFormatter.string(from: formattedDate)
        } else {
            return "Invalid Date"
        }
    }
    //ChatGPT From Here
    private func formatToAMPM(_ time: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH:mm"
        hourFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        //ChatGPT Till Here
        if let date = isoFormatter.date(from: time) {
            return hourFormatter.string(from: date)
        } else {
            return "Invalid Time"
        }
    }
}

extension DailyWeather {
    var weatherCodeImageName: String {
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
        return weatherIconMapping[weatherCode] ?? "Unknown"
    }
}



struct CitySuggestion: Identifiable, Decodable {
    let id = UUID()
    let mainText: String
    let secondaryText: String?

    enum CodingKeys: String, CodingKey {
        case mainText = "main_text"
        case secondaryText = "secondary_text"
    }
}

struct GeocodeResponse: Decodable {
    let results: [GeocodeResult]
    let status: String
}

struct GeocodeResult: Decodable {
    let addressComponents: [AddressComponent]
    let formattedAddress: String
    let geometry: Geometry

    enum CodingKeys: String, CodingKey {
        case addressComponents = "address_components"
        case formattedAddress = "formatted_address"
        case geometry
    }
}

struct AddressComponent: Decodable {
    let longName: String
    let shortName: String
    let types: [String]

    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types
    }
}

struct Geometry: Decodable {
    let location: Location
}

struct Location: Decodable {
    let lat: Double
    let lng: Double
}


#Preview {
    ContentView()
}

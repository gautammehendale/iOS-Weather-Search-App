import SwiftUI
import Highcharts

struct WeatherDetailsView: View {
    var cityData: WeatherData
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = "TODAY"

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
                    .padding(.leading, 10)

                    Spacer()

                    Text(cityData.cityName)
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)

                    Spacer()

                    
                    Button(action: {
                        openTwitter(city: cityData.cityName,
                                    temperature: String(Int(cityData.temperatureApparent)),
                                    conditions: cityData.weatherText())
                    }) {
                        Image("twitter")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 24, height: 24)                    }
                    .padding(.trailing, 10)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                .frame(height: 50)
                .background(Color.white)
                //ChatGPT From Here
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20)
                //ChatGPT Till Here
            }
            .edgesIgnoringSafeArea(.top)

            
            VStack {
                ScrollView {
                    if selectedTab == "TODAY" {
                        todayView()
                    } else if selectedTab == "WEEKLY" {
                        weeklyView()
                    } else {
                        weatherDataView()
                    }
                }

                HStack {
                    Spacer(minLength: 40)
                    Button(action: { selectedTab = "TODAY" }) {
                        VStack(spacing: 5) {
                            Image("Today_Tab")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(selectedTab == "TODAY" ? .blue : .gray)
                                
                            Text("TODAY")
                                .font(.caption)
                                .foregroundColor(selectedTab == "TODAY" ? .blue : .gray)
                        }
                    }
                    Spacer(minLength: 90)
                    Button(action: { selectedTab = "WEEKLY" }) {
                        VStack(spacing: 5) {
                            Image("Weekly_Tab")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(selectedTab == "WEEKLY" ? .blue : .gray)
                            
                            Text("WEEKLY")
                                .font(.caption)
                                .foregroundColor(selectedTab == "WEEKLY" ? .blue : .gray)
                        }
                    }
                    Spacer(minLength: 90)
                    Button(action: { selectedTab = "WEATHER DATA" }) {
                        VStack(spacing: 5) {
                            Image("Weather_Data_Tab")
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(selectedTab == "WEATHER DATA" ? .blue : .gray)
                            Text("WEATHER DATA")
                                .font(.system(size: 10))
                                .foregroundColor(selectedTab == "WEATHER DATA" ? .blue : .gray)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    }
                    .padding(.trailing, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.white)
                .frame(height: 80)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -3)
                }
                .edgesIgnoringSafeArea(.bottom)
            .padding(.top, 70)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func openTwitter(city: String, temperature: String, conditions: String) {

        let tweetText = "The current temperature at \(city) is \(temperature)°F. The weather conditions are \(conditions)"

        guard let encodedTweetText = tweetText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error encoding the tweet text.")
            return
        }

        let twitterPostURL = "https://twitter.com/intent/tweet?text=\(encodedTweetText)"

        if let url = URL(string: twitterPostURL) {
            UIApplication.shared.open(url)
        } else {
            print("This is an invalid Twitter URL.")
        }
    }

    private func todayView() -> some View {
        VStack(spacing: 20) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20)
                ],
                spacing: 30
            ) {
                
                gridItem(icon: "WindSpeed", value: "\(String(format: "%.2f", cityData.windSpeed)) mph", label: "Wind Speed")
                gridItem(icon: "Pressure", value: "\(String(format: "%.0f", cityData.pressureSeaLevel)) inHg", label: "Pressure")
                gridItem(icon: "Precipitation", value: "\(String(format: "%.0f", cityData.precipitation))%", label: "Precipitation")

                gridItem(icon: "Temperature", value: "\(String(Int(cityData.temperatureApparent))) °F", label: "Temperature")
                dynamicWeatherItem(icon: cityData.weatherIcon(), text: cityData.weatherText())
                gridItem(icon: "Humidity", value: "\(String(format: "%.0f", cityData.humidity)) %", label: "Humidity")

                gridItem(icon: "Visibility", value: "\(String(format: "%.2f", cityData.visibility)) mi", label: "Visibility")
                gridItem(icon: "CloudCover", value: "\(String(format: "%.0f", cityData.cloudCover))%", label: "Cloud Cover")
                gridItem(icon: "UVIndex", value: "\(String(format: "%.0f", cityData.uvIndex))", label: "UV Index")
            }
            .padding(.horizontal, 20)
        }
        .padding()
    }

    private func weeklyView() -> some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 20)
            HStack(spacing: 15) {
                Image(cityData.weatherIcon())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .foregroundColor(.black)

                VStack(alignment: .leading, spacing: 30) {
                    Text(cityData.weatherText())
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.leading, 70)

                    Text("\(String(Int(cityData.temperatureApparent)))°F")
                        
                        .font(.largeTitle)
                        
                        .padding(.leading, 70)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: 350)
            .frame(height: 180)
            .padding()
            .background(Color.white.opacity(0.3))
            .cornerRadius(12)
            .shadow(radius: 5)
            .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 1)
                    )
            

            Spacer().frame(height: 20)

            HighchartsChartView(cityData: cityData)
                .frame(height: 300)
                .padding(.top, 20)
        }
        .padding(.horizontal, 20)
    }

    private func weatherDataView() -> some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                VStack(spacing: 20) {
                    HStack(spacing: 15) {
                        Image("Precipitation")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .padding(.leading, 20)

                        Spacer()
                        
                        Text("Precipitation: \(String(format: "%.0f", cityData.precipitation))%")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.trailing, 40)
                    }

                    HStack(spacing: 15) {
                        Image("Humidity")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text("Humidity: \(String(format: "%.0f", cityData.humidity))%")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.trailing, 40)
                    }

                    HStack(spacing: 15) {
                        Image("CloudCover")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text("Cloud Cover: \(String(format: "%.0f", cityData.cloudCover))%")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.trailing, 40)
                    }
                }
                .padding(20)
                .frame(maxWidth: 370)
                .background(Color.white.opacity(0.3))
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white, lineWidth: 1)
                        )
            }
            .padding(.horizontal, 20)

            HighchartsGaugeChartView(cityData: cityData)
                .frame(height: 450)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
        }
        .padding(.top, 20)
    }

    private func gridItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 10) {
            
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.black)

            Text(value)
                .font(.title3)
                .foregroundColor(.black)
                .lineLimit(1)
 
            Text(label)
                .font(.subheadline)
                .foregroundColor(.black)
        }
        .padding()
        .frame(width: 120, height: 170)
        .background(Color.white.opacity(0.3))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}

private func dynamicWeatherItem(icon: String, text: String) -> some View {
    VStack {
        Image(icon)
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
        
        Text(text)
            .font(.title3)
            .foregroundColor(.black)
    }
    .padding()
    .frame(width: 120, height: 170)
    .background(Color.white.opacity(0.3))
    .cornerRadius(12)
    .shadow(radius: 5)
}

struct HighchartsChartView: UIViewRepresentable {
    var cityData: WeatherData

    func makeUIView(context: Context) -> HIChartView {
        let chartView = HIChartView(frame: .zero)
        let options = HIOptions()

        let chart = HIChart()
        chart.type = "arearange"
        options.chart = chart

        let title = HITitle()
        title.text = "Temperature Variation by Day"
        options.title = title

        let xAxis = HIXAxis()
        xAxis.type = "datetime"
        options.xAxis = [xAxis]

        let yAxis = HIYAxis()
        yAxis.title = HITitle()
        yAxis.title.text = "Temperatures"
        options.yAxis = [yAxis]

        let tooltip = HITooltip()
        tooltip.shared = true
        tooltip.valueSuffix = "°F"
        options.tooltip = tooltip

        let temperatures = HIArearange()
        temperatures.name = "Temperatures"
        temperatures.lineColor = HIColor(rgba: 0, green: 0, blue: 0, alpha: 0)
        temperatures.fillColor = HIColor(linearGradient: ["x1": 0, "y1": 0, "x2": 0, "y2": 1],
                                         stops: [
                                            [0, "rgba(237, 206, 150, 1)"],
                                            [1, "rgba(197, 211, 223, 1)"]
                                         ])
        let marker = HIMarker()
        marker.enabled = true
        marker.fillColor = HIColor(hexValue: "000000")
        marker.lineColor = HIColor(hexValue: "000000")
        marker.lineWidth = 1
        temperatures.marker = marker

        temperatures.data = cityData.dailyWeather.map {
            [$0.date.toTimeInterval(), $0.temperatureMin, $0.temperatureMax]
        }
        temperatures.showInLegend = false
        options.series = [temperatures]
        chartView.options = options

        return chartView
    }

    func updateUIView(_ uiView: HIChartView, context: Context) {}
}
struct HighchartsGaugeChartView: UIViewRepresentable {
    var cityData: WeatherData

    func makeUIView(context: Context) -> HIChartView {
        let chartView = HIChartView(frame: .zero)
        let options = HIOptions()

        let chart = HIChart()
        chart.type = "solidgauge"
        chart.height = "110%"
        options.chart = chart

        let title = HITitle()
        title.text = "Weather Data"
        title.style = HICSSObject()
        title.style.fontSize = "20px"
        title.style.color = "#333333"
        options.title = title

        let pane = HIPane()
        pane.startAngle = 0
        pane.endAngle = 360

        let background1 = HIBackground()
        background1.backgroundColor = HIColor(rgba: 202, green: 255, blue: 191, alpha: 0.35)
        background1.outerRadius = "112%"
        background1.innerRadius = "88%"
        background1.borderWidth = 0

        let background2 = HIBackground()
        background2.backgroundColor = HIColor(rgba: 173, green: 216, blue: 230, alpha: 0.35)
        background2.outerRadius = "87%"
        background2.innerRadius = "63%"
        background2.borderWidth = 0

        let background3 = HIBackground()
        background3.backgroundColor = HIColor(rgba: 255, green: 160, blue: 122, alpha: 0.35)
        background3.outerRadius = "62%"
        background3.innerRadius = "38%"
        background3.borderWidth = 0

        pane.background = [background1, background2, background3]
        options.pane = [pane]

        let yAxis = HIYAxis()
        yAxis.min = 0
        yAxis.max = 100
        yAxis.lineWidth = 0
        yAxis.tickPositions = []
        options.yAxis = [yAxis]

        let plotOptions = HIPlotOptions()
        plotOptions.solidgauge = HISolidgauge()
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        plotOptions.solidgauge.dataLabels = [dataLabels]
        plotOptions.solidgauge.linecap = "round"
        plotOptions.solidgauge.stickyTracking = false
        plotOptions.solidgauge.rounded = true
        options.plotOptions = plotOptions

        let cloudCover = HISolidgauge()
        cloudCover.name = "Cloud Cover"
        let cloudCoverData = HIData()
        cloudCoverData.color = HIColor(rgba: 130, green: 238, blue: 106, alpha: 1)
        cloudCoverData.radius = "112%"
        cloudCoverData.innerRadius = "88%"
        cloudCoverData.y = NSNumber(value: cityData.cloudCover)
        cloudCover.data = [cloudCoverData]

        let precipitation = HISolidgauge()
        precipitation.name = "Precipitation"
        let precipitationData = HIData()
        precipitationData.color = HIColor(rgba: 106, green: 165, blue: 231, alpha: 1)
        precipitationData.radius = "87%"
        precipitationData.innerRadius = "63%"
        precipitationData.y = NSNumber(value: cityData.precipitation)
        precipitation.data = [precipitationData]

        let humidity = HISolidgauge()
        humidity.name = "Humidity"
        let humidityData = HIData()
        humidityData.color = HIColor(rgba: 255, green: 99, blue: 71, alpha: 1)
        humidityData.radius = "62%"
        humidityData.innerRadius = "38%"
        humidityData.y = NSNumber(value: cityData.humidity)
        humidity.data = [humidityData]

        options.series = [cloudCover, precipitation, humidity]
        chartView.options = options

        return chartView
    }

    func updateUIView(_ uiView: HIChartView, context: Context) {}
}

extension String {
    func toTimeInterval() -> Double {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: self) {
            return date.timeIntervalSince1970 * 1000
        }
        return 0
    }
}

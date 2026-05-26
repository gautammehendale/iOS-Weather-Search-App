# iOS Weather Search App

A native iOS weather app built with Swift and SwiftUI that delivers real-time weather data for any city with an intuitive swipeable interface, interactive charts, and CoreLocation-based auto-detection.

> **Part of a cross-platform solution** — paired with a [React/Node.js web platform](https://github.com/gautammehendale) backed by a shared MongoDB Atlas database and a Node.js/Express API deployed on Google Cloud App Engine.

---

## Features

- **Auto-detect location** — CoreLocation fetches weather for your current GPS position on launch
- **City search with autocomplete** — Google Places-powered suggestions as you type
- **Favorites** — Add/remove cities; swipe through saved cities with a full-screen paged interface
- **15-day forecast** — Scrollable daily list with weather icons, sunrise and sunset times
- **Detailed weather view** with three tabs:
  - **Today** — 3×3 grid: wind speed, pressure, precipitation, temperature, weather condition, humidity, visibility, cloud cover, UV index
  - **Weekly** — Highcharts area-range chart showing daily temperature highs and lows over 15 days
  - **Weather Data** — Animated Highcharts solid-gauge rings for cloud cover, precipitation, and humidity
- **Share to X (Twitter)** — One-tap tweet with current temperature and conditions
- **Loading spinners & toast notifications** — SwiftSpinner on fetch, Toast-Swift for favorites feedback

---

## Demo

https://github.com/gautammehendale/iOS-Weather-Search-App-/raw/main/WeatherApp_Demo.mp4

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5 |
| UI Framework | SwiftUI |
| Networking | Alamofire 5 |
| JSON Parsing | SwiftyJSON |
| Charts | Highcharts iOS SDK 11 |
| Loading Indicator | SwiftSpinner |
| Toast Notifications | Toast-Swift |
| Location | CoreLocation |
| Geocoding | Google Maps Geocoding API |
| Weather Data | Tomorrow.io API |
| Backend | Node.js / Express on Google Cloud App Engine |
| Database | MongoDB Atlas |

---

## Architecture

MVVM pattern:

```
WeatherApp/
├── WeatherAppEntry.swift       # App entry point (@main)
├── ContentView.swift           # Root view — splash, search bar, paged home
├── PostSlide.swift             # City detail slide (add to favorites, weather summary)
├── WeatherDetailsTabs.swift    # 3-tab detail view + Highcharts chart views
├── DailyWeather.swift          # DailyWeather model (Codable)
├── WeatherViewModel.swift      # ObservableObject — state + business logic
├── WeatherService.swift        # Network layer (Alamofire)
└── IPLocation.swift            # CoreLocation wrapper (LocationManager)
```

**Data flow:**
1. `LocationManager` → publishes GPS coordinates
2. `WeatherViewModel.fetchWeather()` → calls `WeatherService` → hits backend → parses response
3. SwiftUI views observe `@Published` properties and re-render automatically
4. City search: autocomplete endpoint → Google Geocoding → `WeatherService` → `PostSlideView`

---

## Setup

### Requirements
- Xcode 16+
- iOS 17.6+ deployment target
- Swift Package Manager (dependencies resolve automatically)

### Installation

```bash
git clone https://github.com/gautammehendale/iOS-Weather-Search-App-.git
cd iOS-Weather-Search-App-
open WeatherApp.xcodeproj
```

Xcode will automatically resolve SPM packages (Alamofire, Highcharts, SwiftyJSON, SwiftSpinner, Toast-Swift) on first open.

### API Keys

The app uses:
- **Google Maps Geocoding API** — for reverse geocoding (location → city name) and city search geocoding
- **Tomorrow.io API** — served via the Node.js backend

Replace the API key in `WeatherViewModel.swift` and `ContentView.swift` with your own Google Maps key before running.

---

## Dependencies

Managed via Swift Package Manager:

| Package | Version | Purpose |
|---|---|---|
| [Alamofire](https://github.com/Alamofire/Alamofire) | 5.10.1 | HTTP networking |
| [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) | 5.0.2 | JSON parsing |
| [SwiftSpinner](https://github.com/icanzilb/SwiftSpinner) | 2.2.0 | Loading overlay |
| [Toast-Swift](https://github.com/scalessec/Toast-Swift) | 5.1.1 | Toast messages |
| [Highcharts iOS](https://github.com/highcharts/highcharts-ios) | 11.4.8 | Interactive charts |

---

## License

MIT

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=865e136ef7feb08ad54b3a641239c615&units=metric"
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees,longitude: CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude))"
        performRequest(with: urlString)
    }
   
    var delegate: WeatherManagerDelegate?
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration:  .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Error")
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temprature: temp)
            return weather
        }catch {
            delegate?.didFailWithError(error: error)
           print(error)
        }
        return nil
    }

}

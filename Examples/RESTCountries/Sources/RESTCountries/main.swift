import AWSLambdaSwift
import Foundation

struct Input: Codable {
    let countryCode: String
}

struct Country: Codable {
    let name: String
    let capital: String
    let population: Int
}

struct Output: Codable {
    let country: Country?
}

func fetchCountry(input: Input, context: Context, completionHandler: @escaping (Output) -> Void) {
    guard let url = URL(string: "http://restcountries.eu/rest/v2/alpha/\(input.countryCode)") else {
        completionHandler(Output(country: nil))
        return
    }

    let session = URLSession(configuration: .default)
    let dataTask = session.dataTask(with: url) { data, _, error in
        guard error == nil, let data = data else {
            completionHandler(Output(country: nil))
            return
        }

        let jsonDecoder = JSONDecoder()
        guard let country = try? jsonDecoder.decode(Country.self, from: data) else {
            completionHandler(Output(country: nil))
            return
        }

        completionHandler(Output(country: country))
    }
    dataTask.resume()
}

let runtime = try Runtime()
runtime.registerLambda("fetchCountry", handlerFunction: fetchCountry)
try runtime.start()

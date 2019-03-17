import Foundation

extension URLSession {
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        let urlRequest = URLRequest(url: url)
        return synchronousDataTask(with: urlRequest)
    }

    func synchronousDataTask(with urlRequest: URLRequest) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        let dataTask = self.dataTask(with: urlRequest) {
            data = $0
            response = $1
            error = $2

            dispatchGroup.leave()
        }
        dataTask.resume()

        dispatchGroup.wait()
        return (data, response, error)
    }
}

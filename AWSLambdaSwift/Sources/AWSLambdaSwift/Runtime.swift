import Foundation

func log(_ object: Any, flush: Bool = false) {
    fputs("\(object)\n", stderr)
    if flush {
        fflush(stderr)
    }
}

public typealias JSONDictionary = [String: Any]

public class Runtime {
    var counter = 0
    let urlSession: URLSession
    let awsLambdaRuntimeAPI: String
    let handler: String
    var lambdas: [String: (JSONDictionary) -> JSONDictionary]
    
    public init() throws {
        self.urlSession = URLSession.shared
        self.lambdas = [:]
        
        let environment = ProcessInfo.processInfo.environment
        guard let awsLambdaRuntimeAPI = environment["AWS_LAMBDA_RUNTIME_API"],
           let handler = environment["_HANDLER"] else {
              throw RuntimeError.missingEnvironmentVariables
        }
        
        self.awsLambdaRuntimeAPI = awsLambdaRuntimeAPI
        self.handler = handler
    }
    
    func getNextInvocation() throws -> (input: JSONDictionary, requestId: String) {
        let getNextInvocationEndpoint = URL(string: "http://\(awsLambdaRuntimeAPI)/2018-06-01/runtime/invocation/next")!
        let (optData, optResponse, optError) = urlSession.synchronousDataTask(with: getNextInvocationEndpoint)
        
        guard optError == nil else {
            throw RuntimeError.endpointError(optError!.localizedDescription)
        }
        
        guard let data = optData else {
            throw RuntimeError.missingData
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let input = jsonObject as? JSONDictionary else {
            throw RuntimeError.invalidData
        }
        
        let httpResponse = optResponse as! HTTPURLResponse
        let requestId = httpResponse.allHeaderFields["Lambda-Runtime-Aws-Request-Id"] as! String
        return (input: input, requestId: requestId)
    }
    
    func postInvocationResponse(for requestId: String, response: JSONDictionary) throws {
        let postInvocationResponseEndpoint = URL(string: "http://\(awsLambdaRuntimeAPI)/2018-06-01/runtime/invocation/\(requestId)/response")!
        guard let httpBody = try? JSONSerialization.data(withJSONObject: response) else {
            throw RuntimeError.invalidData
        }
        
        var urlRequest = URLRequest(url: postInvocationResponseEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = httpBody
        
        _ = urlSession.synchronousDataTask(with: urlRequest)
    }

    public func registerLambda(_ name: String, handler: @escaping (JSONDictionary) -> JSONDictionary) {
        lambdas[name] = handler
    }
    
    public func start() throws {
        while true {
            let (input, requestId) = try getNextInvocation()
            counter += 1
            log("Invocation-Counter: \(counter)")

            let lambda = lambdas["lambda"]!
            let output = lambda(input)
            try postInvocationResponse(for: requestId, response: output)
        }
    }
}

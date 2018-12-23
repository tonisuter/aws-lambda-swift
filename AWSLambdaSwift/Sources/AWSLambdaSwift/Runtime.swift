import Foundation

public func log(_ object: Any, flush: Bool = false) {
    fputs("\(object)\n", stderr)
    if flush {
        fflush(stderr)
    }
}

public typealias JSONDictionary = [String: Any]
public typealias Handler = (JSONDictionary, Context) -> JSONDictionary

public class Runtime {
    var counter = 0
    let urlSession: URLSession
    let awsLambdaRuntimeAPI: String
    let lambdaName: String
    var lambdas: [String: Handler]
    
    public init() throws {
        self.urlSession = URLSession.shared
        self.lambdas = [:]
        
        let environment = ProcessInfo.processInfo.environment
        guard let awsLambdaRuntimeAPI = environment["AWS_LAMBDA_RUNTIME_API"],
           let handler = environment["_HANDLER"] else {
              throw RuntimeError.missingEnvironmentVariables
        }

        guard let periodIndex = handler.index(of: ".") else {
            throw RuntimeError.invalidHandlerName
        }

        self.awsLambdaRuntimeAPI = awsLambdaRuntimeAPI
        self.lambdaName = String(handler[handler.index(after: periodIndex)...])
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

    func createContext(requestId: String) -> Context {
        let environment = ProcessInfo.processInfo.environment
        let functionName = environment["AWS_LAMBDA_FUNCTION_NAME"] ?? ""
        let functionVersion = environment["AWS_LAMBDA_FUNCTION_VERSION"] ?? ""
        let logGroupName = environment["AWS_LAMBDA_LOG_GROUP_NAME"] ?? ""
        let logStreamName = environment["AWS_LAMBDA_LOG_STREAM_NAME"] ?? ""
        return Context(functionName: functionName,
                        functionVersion: functionVersion,
                        logGroupName: logGroupName,
                        logStreamName: logStreamName,
                        requestId: requestId)
    }

    public func registerLambda(_ name: String, handler: @escaping Handler) {
        lambdas[name] = handler
    }
    
    public func start() throws {
        while true {
            let (input, requestId) = try getNextInvocation()
            counter += 1
            log("Invocation-Counter: \(counter)")

            guard let lambda = lambdas[lambdaName] else {
                throw RuntimeError.unknownLambdaHandler
            }

            let context = createContext(requestId: requestId)
            let output = lambda(input, context)
            try postInvocationResponse(for: requestId, response: output)
        }
    }
}

import Foundation

public func log(_ object: Any, flush: Bool = false) {
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
    let lambdaName: String
    var lambdas: [String: HandlerProtocol]
    
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
    
    func getNextInvocation() throws -> (inputData: Data, requestId: String, invokedFunctionArn: String) {
        let getNextInvocationEndpoint = URL(string: "http://\(awsLambdaRuntimeAPI)/2018-06-01/runtime/invocation/next")!
        let (optData, optResponse, optError) = urlSession.synchronousDataTask(with: getNextInvocationEndpoint)
        
        guard optError == nil else {
            throw RuntimeError.endpointError(optError!.localizedDescription)
        }
        
        guard let inputData = optData else {
            throw RuntimeError.missingData
        }
        
        let httpResponse = optResponse as! HTTPURLResponse
        let requestId = httpResponse.allHeaderFields["Lambda-Runtime-Aws-Request-Id"] as! String
        let invokedFunctionArn = httpResponse.allHeaderFields["Lambda-Runtime-Invoked-Function-Arn"] as! String
        return (inputData: inputData, requestId: requestId, invokedFunctionArn: invokedFunctionArn)
    }
    
    func postInvocationResponse(for requestId: String, httpBody: Data) {
        let postInvocationResponseEndpoint = URL(string: "http://\(awsLambdaRuntimeAPI)/2018-06-01/runtime/invocation/\(requestId)/response")!
        var urlRequest = URLRequest(url: postInvocationResponseEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = httpBody
        _ = urlSession.synchronousDataTask(with: urlRequest)
    }

    func createContext(requestId: String, invokedFunctionArn: String) -> Context {
        let environment = ProcessInfo.processInfo.environment
        let functionName = environment["AWS_LAMBDA_FUNCTION_NAME"] ?? ""
        let functionVersion = environment["AWS_LAMBDA_FUNCTION_VERSION"] ?? ""
        let logGroupName = environment["AWS_LAMBDA_LOG_GROUP_NAME"] ?? ""
        let logStreamName = environment["AWS_LAMBDA_LOG_STREAM_NAME"] ?? ""
        return Context(functionName: functionName,
                        functionVersion: functionVersion,
                        logGroupName: logGroupName,
                        logStreamName: logStreamName,
                        awsRequestId: requestId,
                        invokedFunctionArn: invokedFunctionArn)
    }

    public func registerLambda(_ name: String, handlerFunction: @escaping (JSONDictionary, Context) -> JSONDictionary) {
        let handler = JSONSerializationHandler(handlerFunction: handlerFunction)
        lambdas[name] = handler
    }

    public func registerLambda<Input: Decodable, Output: Encodable>(_ name: String, handlerFunction: @escaping (Input, Context) -> Output) {
        let handler = CodableHandler(handlerFunction: handlerFunction)
        lambdas[name] = handler
    }
    
    public func start() throws {
        while true {
            let (inputData, requestId, invokedFunctionArn) = try getNextInvocation()
            counter += 1
            log("Invocation-Counter: \(counter)")

            guard let lambda = lambdas[lambdaName] else {
                throw RuntimeError.unknownLambdaHandler
            }

            let context = createContext(requestId: requestId, invokedFunctionArn: invokedFunctionArn)
            let outputData = try lambda.apply(inputData: inputData, context: context)
            postInvocationResponse(for: requestId, httpBody: outputData)
        }
    }
}

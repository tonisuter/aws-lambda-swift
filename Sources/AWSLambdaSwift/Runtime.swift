import Foundation

public func log(_ object: Any, flush: Bool = false) {
    fputs("\(object)\n", stderr)
    if flush {
        fflush(stderr)
    }
}

public typealias JSONDictionary = [String: Any]

struct InvocationError: Codable {
    let errorMessage: String
    let errorType: String
}

public class Runtime {
    let urlSession: URLSession
    let awsLambdaRuntimeAPI: String
    let handlerName: String
    var handlers: [String: Handler]

    public init() throws {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3600

        
        self.urlSession = URLSession(configuration: configuration)
        self.handlers = [:]

        let environment = ProcessInfo.processInfo.environment
        guard let awsLambdaRuntimeAPI = environment["AWS_LAMBDA_RUNTIME_API"],
            let handler = environment["_HANDLER"] else {
            throw RuntimeError.missingEnvironmentVariables
        }

        guard let periodIndex = handler.firstIndex(of: ".") else {
            throw RuntimeError.invalidHandlerName
        }

        self.awsLambdaRuntimeAPI = awsLambdaRuntimeAPI
        self.handlerName = String(handler[handler.index(after: periodIndex)...])
    }

    func getNextInvocation() throws -> (inputData: Data, responseHeaderFields: [AnyHashable: Any]) {
        let getNextInvocationEndpoint = URL(string: "http://\(awsLambdaRuntimeAPI)/2018-06-01/runtime/invocation/next")!
        let (optData, optResponse, optError) = urlSession.synchronousDataTask(with: getNextInvocationEndpoint)

        guard optError == nil else {
            throw RuntimeError.endpointError(optError!.localizedDescription)
        }

        guard let inputData = optData else {
            throw RuntimeError.missingData
        }

        let httpResponse = optResponse as! HTTPURLResponse
        return (inputData: inputData, responseHeaderFields: httpResponse.allHeaderFields)
    }

    func postInvocationResponse(for requestId: String, httpBody: Data) {
        let postInvocationResponseEndpoint = URL(string: "http://\(awsLambdaRuntimeAPI)/2018-06-01/runtime/invocation/\(requestId)/response")!
        var urlRequest = URLRequest(url: postInvocationResponseEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = httpBody
        _ = urlSession.synchronousDataTask(with: urlRequest)
    }

    func postInvocationError(for requestId: String, error: Error) {
        let errorMessage = error.localizedDescription
        let invocationError = InvocationError(errorMessage: errorMessage,
                                              errorType: "PostInvocationError")
        let jsonEncoder = JSONEncoder()
        let httpBody = try? jsonEncoder.encode(invocationError)

        let postInvocationErrorEndpoint = URL(string: "http://\(awsLambdaRuntimeAPI)/2018-06-01/runtime/invocation/\(requestId)/error")!
        var urlRequest = URLRequest(url: postInvocationErrorEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = httpBody
        _ = urlSession.synchronousDataTask(with: urlRequest)
    }

    public func registerLambda(_ name: String, handlerFunction: @escaping (JSONDictionary, Context) throws -> JSONDictionary) {
        let handler = JSONSyncHandler(handlerFunction: handlerFunction)
        handlers[name] = .sync(handler)
    }

    public func registerLambda(_ name: String,
                               handlerFunction: @escaping (JSONDictionary, Context, @escaping (JSONDictionary) -> Void) -> Void) {
        let handler = JSONAsyncHandler(handlerFunction: handlerFunction)
        handlers[name] = .async(handler)
    }

    public func registerLambda<Input: Decodable, Output: Encodable>(_ name: String, handlerFunction: @escaping (Input, Context) throws -> Output) {
        let handler = CodableSyncHandler(handlerFunction: handlerFunction)
        handlers[name] = .sync(handler)
    }

    public func registerLambda<Input: Decodable, Output: Encodable>(_ name: String,
                                                                    handlerFunction: @escaping (Input, Context, @escaping (Output) -> Void) -> Void) {
        let handler = CodableAsyncHandler(handlerFunction: handlerFunction)
        handlers[name] = .async(handler)
    }

    public func start() throws {
        var counter = 0

        while true {
            let (inputData, responseHeaderFields) = try getNextInvocation()
            counter += 1
            log("Invocation-Counter: \(counter)")

            guard let handler = handlers[handlerName] else {
                throw RuntimeError.unknownLambdaHandler
            }

            if let lambdaRuntimeTraceId = responseHeaderFields["Lambda-Runtime-Trace-Id"] as? String {
                setenv("_X_AMZN_TRACE_ID", lambdaRuntimeTraceId, 0)
            }

            let environment = ProcessInfo.processInfo.environment
            let context = Context(environment: environment, responseHeaderFields: responseHeaderFields)
            let result = handler.apply(inputData: inputData, context: context)

            switch result {
            case .success(let outputData):
                postInvocationResponse(for: context.awsRequestId, httpBody: outputData)
            case .failure(let error):
                postInvocationError(for: context.awsRequestId, error: error)
            }
        }
    }
}

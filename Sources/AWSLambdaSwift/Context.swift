public struct Context {
    public var functionName: String
    public var functionVersion: String
    public var logGroupName: String
    public var logStreamName: String
    public var memoryLimitInMB: String
    public var awsRequestId: String
    public var invokedFunctionArn: String

    public init(environment: [String: String], responseHeaderFields: [AnyHashable: Any]) {
        self.functionName = environment["AWS_LAMBDA_FUNCTION_NAME"] ?? ""
        self.functionVersion = environment["AWS_LAMBDA_FUNCTION_VERSION"] ?? ""
        self.logGroupName = environment["AWS_LAMBDA_LOG_GROUP_NAME"] ?? ""
        self.logStreamName = environment["AWS_LAMBDA_LOG_STREAM_NAME"] ?? ""
        self.memoryLimitInMB = environment["AWS_LAMBDA_FUNCTION_MEMORY_SIZE"] ?? ""
        self.awsRequestId = responseHeaderFields["Lambda-Runtime-Aws-Request-Id"] as! String
        self.invokedFunctionArn = responseHeaderFields["Lambda-Runtime-Invoked-Function-Arn"] as! String
    }
}
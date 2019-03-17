import Foundation

public struct Context {
    public let functionName: String
    public let functionVersion: String
    public let logGroupName: String
    public let logStreamName: String
    public let memoryLimitInMB: String
    public let awsRequestId: String
    public let invokedFunctionArn: String
    private let deadlineDate: Date

    public init(environment: [String: String], responseHeaderFields: [AnyHashable: Any]) {
        self.functionName = environment["AWS_LAMBDA_FUNCTION_NAME"] ?? ""
        self.functionVersion = environment["AWS_LAMBDA_FUNCTION_VERSION"] ?? ""
        self.logGroupName = environment["AWS_LAMBDA_LOG_GROUP_NAME"] ?? ""
        self.logStreamName = environment["AWS_LAMBDA_LOG_STREAM_NAME"] ?? ""
        self.memoryLimitInMB = environment["AWS_LAMBDA_FUNCTION_MEMORY_SIZE"] ?? ""
        self.awsRequestId = responseHeaderFields["Lambda-Runtime-Aws-Request-Id"] as! String
        self.invokedFunctionArn = responseHeaderFields["Lambda-Runtime-Invoked-Function-Arn"] as! String
        let timeInterval = TimeInterval(responseHeaderFields["Lambda-Runtime-Deadline-Ms"] as! String)! / 1000
        self.deadlineDate = Date(timeIntervalSince1970: timeInterval)
    }

    public func getRemainingTimeInMillis() -> Int {
        let remainingTimeInSeconds = deadlineDate.timeIntervalSinceNow
        return Int(remainingTimeInSeconds * 1000)
    }
}

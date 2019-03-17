enum RuntimeError: Error {
    case missingEnvironmentVariables
    case invalidHandlerName
    case endpointError(String)
    case missingData
    case invalidData
    case unknownLambdaHandler
}

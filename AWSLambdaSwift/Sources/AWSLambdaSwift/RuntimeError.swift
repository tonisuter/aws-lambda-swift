enum RuntimeError: Error {
    case missingEnvironmentVariables
    case endpointError(String)
    case missingData
    case invalidData
}
import Foundation

typealias HandlerResult = Result<Data, Error>

protocol SyncHandler {
    func apply(inputData: Data, context: Context) throws -> Data
}

protocol AsyncHandler {
    func apply(inputData: Data, context: Context, completion: @escaping (HandlerResult) -> Void)
}

enum Handler {
    case sync(SyncHandler)
    case async(AsyncHandler)

    func apply(inputData: Data, context: Context) -> HandlerResult {
        switch self {
        case .sync(let handler):
            do {
                let outputData = try handler.apply(inputData: inputData, context: context)
                return .success(outputData)
            } catch {
                return .failure(error)
            }
        case .async(let handler):
            var handlerResult: HandlerResult?
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            handler.apply(inputData: inputData, context: context) { result in
                handlerResult = result
                dispatchGroup.leave()
            }
            dispatchGroup.wait()
            return handlerResult!
        }
    }
}

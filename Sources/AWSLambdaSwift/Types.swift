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
}

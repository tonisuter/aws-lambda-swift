import Foundation

//Remove when moving to swift 5
enum HandlerResult {
    case success(Data)
    case failure(Error)
}

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

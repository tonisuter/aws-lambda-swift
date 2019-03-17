import Foundation

private func jsonObject(with data: Data) throws -> JSONDictionary {
    guard let jsonObject = try? JSONSerialization.jsonObject(with: data),
        let event = jsonObject as? JSONDictionary else {
        throw RuntimeError.invalidData
    }
    return event
}

private func jsonSerializationData(with object: JSONDictionary) throws -> Data {
    guard let resultData = try? JSONSerialization.data(withJSONObject: object) else {
        throw RuntimeError.invalidData
    }
    return resultData
}

class JSONSyncHandler: SyncHandler {
    let handlerFunction: (JSONDictionary, Context) throws -> JSONDictionary

    init(handlerFunction: @escaping (JSONDictionary, Context) throws -> JSONDictionary) {
        self.handlerFunction = handlerFunction
    }

    func apply(inputData: Data, context: Context) throws -> Data {
        let event = try jsonObject(with: inputData)
        let result = try handlerFunction(event, context)
        return try jsonSerializationData(with: result)
    }
}

class JSONAsyncHandler: AsyncHandler {
    let handlerFunction: (JSONDictionary, Context, @escaping (JSONDictionary) -> Void) -> Void

    init(handlerFunction: @escaping (JSONDictionary, Context, @escaping (JSONDictionary) -> Void) -> Void) {
        self.handlerFunction = handlerFunction
    }

    func apply(inputData: Data, context: Context, completion: @escaping (HandlerResult) -> Void) {
        do {
            let input = try jsonObject(with: inputData)
            handlerFunction(input, context) { outputDict in
                do {
                    let outputData = try jsonSerializationData(with: outputDict)
                    completion(.success(outputData))
                } catch {
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}

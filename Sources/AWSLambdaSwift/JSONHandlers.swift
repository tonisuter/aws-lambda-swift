import Foundation

private func jsonObject(with data: Data) throws -> JSONDictionary {
    guard let jsonObject = try? JSONSerialization.jsonObject(with: data),
        let jsonDictionary = jsonObject as? JSONDictionary else {
        throw RuntimeError.invalidData
    }
    return jsonDictionary
}

private func jsonSerializationData(with object: JSONDictionary) throws -> Data {
    guard let data = try? JSONSerialization.data(withJSONObject: object) else {
        throw RuntimeError.invalidData
    }
    return data
}

class JSONSyncHandler: SyncHandler {
    let handlerFunction: (JSONDictionary, Context) throws -> JSONDictionary

    init(handlerFunction: @escaping (JSONDictionary, Context) throws -> JSONDictionary) {
        self.handlerFunction = handlerFunction
    }

    func apply(inputData: Data, context: Context) throws -> Data {
        let input = try jsonObject(with: inputData)
        let output = try handlerFunction(input, context)
        return try jsonSerializationData(with: output)
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

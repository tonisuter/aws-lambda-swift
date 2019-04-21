import Foundation

fileprivate func jsonObject(with data: Data) throws -> JSONDictionary {
    guard let jsonObject = try? JSONSerialization.jsonObject(with: data),
        let jsonDictionary = jsonObject as? JSONDictionary else {
        throw RuntimeError.invalidData
    }
    return jsonDictionary
}

fileprivate func jsonSerializationData(with object: JSONDictionary) throws -> Data {
    guard let data = try? JSONSerialization.data(withJSONObject: object) else {
        throw RuntimeError.invalidData
    }
    return data
}

struct JSONSyncHandler: SyncHandler {
    let handlerFunction: (JSONDictionary, Context) throws -> JSONDictionary

    func apply(inputData: Data, context: Context) throws -> Data {
        let input = try jsonObject(with: inputData)
        let output = try handlerFunction(input, context)
        return try jsonSerializationData(with: output)
    }
}

struct JSONAsyncHandler: AsyncHandler {
    let handlerFunction: (JSONDictionary, Context, @escaping (JSONDictionary) -> Void) -> Void

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

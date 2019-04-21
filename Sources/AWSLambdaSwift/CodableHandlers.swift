import Foundation

fileprivate func decodeInput<T: Decodable>(from inputData: Data) throws -> T {
    let jsonDecoder = JSONDecoder()
    guard let input = try? jsonDecoder.decode(T.self, from: inputData) else {
        throw RuntimeError.invalidData
    }
    return input
}

fileprivate func encodeOutput<T: Encodable>(_ output: T) throws -> Data {
    let jsonEncoder = JSONEncoder()
    guard let outputData = try? jsonEncoder.encode(output) else {
        throw RuntimeError.invalidData
    }
    return outputData
}

struct CodableSyncHandler<Input: Decodable, Output: Encodable>: SyncHandler {
    let handlerFunction: (Input, Context) throws -> Output

    func apply(inputData: Data, context: Context) throws -> Data {
        let input = try decodeInput(from: inputData) as Input
        let output = try handlerFunction(input, context)
        return try encodeOutput(output)
    }
}

struct CodableAsyncHandler<Input: Decodable, Output: Encodable>: AsyncHandler {
    let handlerFunction: (Input, Context, @escaping (Output) -> Void) -> Void

    func apply(inputData: Data, context: Context, completion: @escaping (HandlerResult) -> Void) {
        do {
            let input = try decodeInput(from: inputData) as Input
            handlerFunction(input, context) { output in
                do {
                    let outputData = try encodeOutput(output)
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

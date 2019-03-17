import Foundation

private func input<T: Decodable>(from inputData: Data) throws -> T {
    let jsonDecoder = JSONDecoder()
    guard let input = try? jsonDecoder.decode(T.self, from: inputData) else {
        throw RuntimeError.invalidData
    }
    return input
}

private func outputData<T: Encodable>(from output: T) throws -> Data {
    let jsonEncoder = JSONEncoder()
    guard let outputData = try? jsonEncoder.encode(output) else {
        throw RuntimeError.invalidData
    }

    return outputData
}

class CodableSyncHandler<Input: Decodable, Output: Encodable>: SyncHandler {
    let handlerFunction: (Input, Context) throws -> Output

    init(handlerFunction: @escaping (Input, Context) throws -> Output) {
        self.handlerFunction = handlerFunction
    }

    func apply(inputData: Data, context: Context) throws -> Data {
        let fInput = try input(from: inputData) as Input
        let output = try handlerFunction(fInput, context)
        return try outputData(from: output)
    }
}

class CodableAsyncHandler<Input: Decodable, Output: Encodable>: AsyncHandler {
    let handlerFunction: (Input, Context, @escaping (Output) -> Void) -> Void

    init(handlerFunction: @escaping (Input, Context, @escaping (Output) -> Void) -> Void) {
        self.handlerFunction = handlerFunction
    }

    func apply(inputData: Data, context: Context, completion: @escaping (HandlerResult) -> Void) {
        do {
            let fInput = try input(from: inputData) as Input
            handlerFunction(fInput, context) { output in
                do {
                    let fOutputData = try outputData(from: output)
                    completion(.success(fOutputData))
                } catch {
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}

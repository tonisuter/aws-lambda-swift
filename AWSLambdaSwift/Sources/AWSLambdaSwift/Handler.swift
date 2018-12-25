import Foundation

protocol Handler {
    func apply(inputData: Data, context: Context) throws -> Data
}

class JSONSerializationHandler: Handler {
	let handlerFunction: (JSONDictionary, Context) -> JSONDictionary
	
	init(handlerFunction: @escaping (JSONDictionary, Context) -> JSONDictionary) {
		self.handlerFunction = handlerFunction
	}
	
	func apply(inputData: Data, context: Context) throws -> Data {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: inputData),
            let input = jsonObject as? JSONDictionary else {
            throw RuntimeError.invalidData
        }

        let output = handlerFunction(input, context)

        guard let outputData = try? JSONSerialization.data(withJSONObject: output) else {
            throw RuntimeError.invalidData
        }
		return outputData
	}	
}

class CodableHandler<Input: Decodable, Output: Encodable>: Handler {
	let handlerFunction: (Input, Context) -> Output
	
	init(handlerFunction: @escaping (Input, Context) -> Output) {
		self.handlerFunction = handlerFunction
	}
	
	func apply(inputData: Data, context: Context) throws -> Data {
		let jsonDecoder = JSONDecoder()
		guard let input = try? jsonDecoder.decode(Input.self, from: inputData) else {
            throw RuntimeError.invalidData
        }
		
        let output = handlerFunction(input, context)

        let jsonEncoder = JSONEncoder()
        guard let outputData = try? jsonEncoder.encode(output) else {
            throw RuntimeError.invalidData
        }
		return outputData
	}
}
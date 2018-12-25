import Foundation

protocol Handler {
    func apply(eventData: Data, context: Context) throws -> Data
}

class JSONSerializationHandler: Handler {
	let handlerFunction: (JSONDictionary, Context) throws -> JSONDictionary
	
	init(handlerFunction: @escaping (JSONDictionary, Context) throws -> JSONDictionary) {
		self.handlerFunction = handlerFunction
	}
	
	func apply(eventData: Data, context: Context) throws -> Data {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: eventData),
            let event = jsonObject as? JSONDictionary else {
            throw RuntimeError.invalidData
        }

        let result = try handlerFunction(event, context)

        guard let resultData = try? JSONSerialization.data(withJSONObject: result) else {
            throw RuntimeError.invalidData
        }
		return resultData
	}	
}

class CodableHandler<Event: Decodable, Result: Encodable>: Handler {
	let handlerFunction: (Event, Context) throws -> Result
	
	init(handlerFunction: @escaping (Event, Context) throws -> Result) {
		self.handlerFunction = handlerFunction
	}
	
	func apply(eventData: Data, context: Context) throws -> Data {
		let jsonDecoder = JSONDecoder()
		guard let event = try? jsonDecoder.decode(Event.self, from: eventData) else {
            throw RuntimeError.invalidData
        }
		
        let result = try handlerFunction(event, context)

        let jsonEncoder = JSONEncoder()
        guard let resultData = try? jsonEncoder.encode(result) else {
            throw RuntimeError.invalidData
        }
		return resultData
	}
}
import AWSLambdaSwift

struct Event: Codable {
    let number: Double
}

struct Result: Codable {
    let result: Double
}

func squareNumber(event: Event, context: Context) -> Result {
    let squaredNumber = event.number * event.number
    return Result(result: squaredNumber)
}

let runtime = try Runtime()
runtime.registerLambda("squareNumber", handlerFunction: squareNumber)
try runtime.start()
